# Frends Task definition classes

**Baseline:** Frends 6.2

Each imported [Task](../concepts/task.md) brings classes you can use in C#. Example: the HTTP Request
Task expects headers as an array of `Frends.HTTP.Request.Definitions.Header`. Build it in a
[Code Task](../shapes/code-task.md):

```csharp
{
    var headerList = new List<Frends.HTTP.Request.Definitions.Header>();
    headerList.Add(new Frends.HTTP.Request.Definitions.Header {
        Name = "Content-type",
        Value = "application/json"
    });
    return headerList.ToArray();
}
```

Then reference the resulting variable in the Task's headers field.

To find what object a Task field expects: check the field tooltip, the Task's docs, or the Task
source on the `FrendsPlatform` GitHub org. The result object's fields (what you read via
`#result[Task].Field`) come from the same source.

## Related
[reference-syntax.md](reference-syntax.md) · [../shapes/task.md](../shapes/task.md).
