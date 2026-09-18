# Structured-flow rules for decision gateways

**Category:** process-file-format · **Baseline:** Frends 6.3 (import-parser behavior)

## Purpose
The Frends import parser requires structured (properly nested) flow graphs, not
arbitrary BPMN. Violations fail import with:

```
There was an error while parsing the file (All branches of decision node <id> must join at the same node.)
```

## The rule
For every exclusive gateway, each outgoing branch must either **terminate** (reach a
Return / Throw / end event of its own) or **reconverge at the same single node** as the
other branches. Reconvergence defines a region; a nested gateway inside a branch must
join inside that region (or at the region's own join node), never at a node outside it.

## What passes
- Diamond: yes → shapes → J, no → J (skip). Both branches join at one node J.
- Alternative diamond: yes → chain A → J, no → chain B → J.
- Early exit: yes → continues, no → error shapes → **its own end event / Throw**.
  Terminating branches are exempt from the join requirement (the standard outer
  pattern - yes → Return, no → Throw - is exactly this).
- A tree where every gateway's no-branch flows into the scope's single inner end and
  every region therefore shares that end as its join node.

## What fails
A gateway nested inside a reconverging region whose error branch flows to the scope's
shared inner end: the branch escapes the enclosing region, so its join (the scope end)
differs from the sibling branch's join (the region's node).

## Design implication for generated processes
Two envelope styles compose cleanly; do not mix them inside one scope:

1. **Tree style** (no mid-lane reconvergence): every no-branch converges on the single
   inner end. Works when else-branches never need to resume the lane.
2. **Diamond style** (optional steps / create-vs-update forks that resume the lane):
   let each error branch terminate in its **own** Return shape carrying the response
   envelope. Multiple Return shapes in one scope are valid; whichever executes supplies
   the scope result.

## Related
[exception-handler-rules.md](exception-handler-rules.md) ·
[canvas-layout-conventions.md](canvas-layout-conventions.md) ·
[node-naming.md](node-naming.md)

## Source of truth
Parser behavior observed on Frends 6.3 imports; the platform docs do not document the
structured-join requirement explicitly.
