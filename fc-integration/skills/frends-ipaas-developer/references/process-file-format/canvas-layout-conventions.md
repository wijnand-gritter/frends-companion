# Canvas layout conventions for generated Processes

**Category:** process-file-format · **Baseline:** Frends 6.3 (calibrated against hand-arranged editor exports)

## Purpose
The BPMN DI conventions that make a generated Process read like one arranged by hand in
the Frends editor. Coordinates below are the calibrated values; treat them as the house
style, not hard platform requirements.

## Shape sizes by role
- Tasks, Call Subprocess shapes, and **every Code shape holding real logic** (transforms,
  error builders): **100x80**, centered on their lane.
- Trivial one-line assigns (initialize a variable, set a correlation id): **30x30** dots.
- Events 36x36, gateways 50x50.
Drawing content-heavy code shapes as 30x30 dots is the giveaway of a generated canvas;
the editor style sizes them like tasks so their names are readable.

## Main lane
One horizontal lane (center y = 170). Edge-to-edge gaps are small: ~54 before a task,
~60 before a gateway or dot, ~70 before a 100x80 code/call shape. Trigger starts at
x = 52. The lane runs trigger → assigns → scope → final gateway → Return, with the Throw
directly below the Return (center y = lane + 120).

## Error rails inside a scope
- A gateway's "no" branch drops from the **gateway bottom**, turns right at rail height,
  and enters the first error shape **from the left** (not from the top).
- Rail center y = lane + 140; the group starts at gateway-center + 65; ~80 px gaps within
  the group.
- The rail's return runs right and enters the scope's inner end event **from below at its
  center x**. The inner end event sits just right of all rail content (~28 px).
- With multiple "no" branches, **earlier gateways take deeper rails** (each +130) so a
  later gateway's drop never crosses an earlier group's shapes; risers converge under the
  inner end event. Perpendicular riser/rail crossings are acceptable; edges through
  shapes are not.

## Containers
- Scope: left edge 40 px before the inner start, ~74 px after the inner end, 80 px above
  the lane (label band), 60 px below the deepest rail.
- Catch subprocess sits **directly below the scope near its left edge**: the error flow
  drops as one straight vertical from the scope bottom at scope.x + 80 into the catch
  event; the catch box starts 100 px right of the catch event's center, contents on one
  lane (start, 100x80 shapes with 44-50 px gaps, end), 100 px padding above/below the
  lane.
- Catch return: exits the catch box's right edge, runs right, rises at ~70 px left of the
  final gateway, and enters the gateway from the left on the main lane.

## Compactness
No dead horizontal space. The final gateway sits ~160 px after the scope's right edge:
just enough for the catch riser. Total canvas width for a simple API process is
~1700-1800 px, not 2000+.

## Tags
Integration processes carry the tags of the systems they connect (e.g.
`"Tags": ["AFAS", "HubSpot"]`) so the process list filters cleanly.

## Related
[node-naming.md](node-naming.md) ·
[confirmed-shape-parameters.md](confirmed-shape-parameters.md)

## Source of truth
Calibrated against processes arranged by hand in the Frends 6.3 editor and re-exported;
the editor itself accepts any geometry.
