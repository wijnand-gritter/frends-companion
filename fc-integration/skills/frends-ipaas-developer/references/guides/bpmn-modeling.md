# Guide: BPMN modeling in Frends

How to design a Process that is correct, readable, and debuggable. Frends uses BPMN 2.0, but the way
you assemble shapes has Frends-specific conventions. For the detail of any single shape, see
[../shapes/](../shapes/); for field types and references, see [../expressions/](../expressions/).

## The skeleton of every Process
Every Process starts at a [Trigger](../triggers/) and ends at a [Return](../shapes/return.md) (normal
completion, optionally returning a value) or a [Throw](../shapes/throw.md) (error). Shapes between
them are connected with the **Connect** tool. A minimal Process: Trigger → Task → Return.

## Building a flow step by step
1. Start from the provided Trigger. Choose its type ([Manual](../triggers/manual.md),
   [Schedule](../triggers/schedule.md), [API](../triggers/api.md), [File](../triggers/file.md),
   [Conditional](../triggers/conditional.md)) and define any parameters.
2. Add a [Task](../shapes/task.md) shape, select its Task type; fill parameters, choosing
   Expression or Text per field ([../expressions/field-types.md](../expressions/field-types.md)).
3. Connect the Trigger to the Task.
4. Continue adding and connecting shapes ([Code Task](../shapes/code-task.md),
   [Decision](../shapes/exclusive-decision.md), [Assign Variable](../shapes/assign-variable.md),
   [Loop](../shapes/loop.md), [Call Subprocess](../shapes/call-subprocess.md)).
5. End each path with a Return or a Throw.
6. Validate (runs the C# compiler; does not save) and save (also validates; won't complete with
   errors). Add a short version comment.

To return a Task's output, set the Return field to **Expression** and reference the result, e.g.
`#result[HTTP Request].Body`. As Text, the reference is not evaluated.

## Branching, loops, error handling, subprocesses
- Branching: [Exclusive](../shapes/exclusive-decision.md) for either/or,
  [Inclusive](../shapes/inclusive-decision.md) when several branches can run.
- Loops: [Loop shapes](../shapes/loop.md). Keep bodies small and per-item logic in named shapes.
- Error handling: design for failure explicitly — see [error-handling.md](error-handling.md).
- Subprocesses: factor reusable logic into a [Subprocess](../concepts/subprocess.md); mind the
  deploy-order constraint ([deployment.md](deployment.md)).

## Making executions debuggable
Name shapes meaningfully (the name is also the `#result[...]` key), split logic into shapes rather
than one big Code Task, and promote key values. Detail in [debugging.md](debugging.md).

## A worked example
An API-triggered Process that takes an order, enriches it from a CRM, and forwards it to an ERP, with
a guard if the customer is not found.

```
[API Trigger: POST /orders]
   -> (Code Task or Assign Variable: parse #trigger body into #var.order)
   -> [Task: HTTP Request "Get Customer"]
        url:    Expression  $"https://crm/api/customers/{#var.order.CustomerId}"
        method: GET
   -> [Exclusive Decision: customer found?]
        expression (C#, bool):  #result[Get Customer].StatusCode == 200
        -- Yes -->
            [Task: HTTP Request "Post To ERP"]   body: Expression #result[Get Customer].Body
            -> [Return]  value: Expression #result[Post To ERP].Body
        -- No (Default) -->
            [Throw: "Customer {{#var.order.CustomerId}} not found"]
```

What makes this Frends-correct: the URL is an Expression because it interpolates a variable; the
Decision is a boolean C# expression on the prior Task's result; the Throw message uses Handlebars in
a Text field; result references use the shapes' display names. Confirm the HTTP Request Task's exact
result fields (`.StatusCode`, `.Body`) from its tooltip or source before relying on them.
