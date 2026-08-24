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

**When a container collapses into a single shape, close the gap; do not centre the survivor
in the old footprint.** Replacing a 686 px While box with one 100x80 Task and placing that
Task at the box's centre leaves ~290 px of dead space on each side of every affected row.
The layout still validates and imports, so nothing complains - it just reads as sloppy and
the canvas stays as wide as the construct you removed. Instead: place the survivor at the
predecessor's normal gap, then shift everything to its right left by
`(container width - shape width)` and shrink any enclosing container by the same amount.
Observed cost of skipping this: a process that should have been 1885 px wide stayed 2528,
and a developer had to move 31 shapes by hand.

## Color legend (semantic, never decorative)
**A default, not a rule.** The principle is universal: a color states what kind of step a shape is,
identically in every process, so a reviewer finds every side effect and every failure path without
reading a label. The specific assignment below is one workable set; an organisation may choose
differently, and should then record its own legend in its own standards document and follow that
instead of this table.

| Color | Hex | Meaning |
|---|---|---|
| Red | `#ff8282` | Error path: error-response builders, error-handler calls, Throws |
| Orange | `#ffbb95` | External **write** (side effects): inserts, updates, patches, sends |
| Blue | `#78d8ff` | External **read**: lookups, list and search calls, batch reads |
| Purple | `#aa8dfa` | Persistent state: Shared State gets/sets, watermarks |
| Pink | `#ffb4de` | Waiting / throttling: backoff shapes, retry loops |
| Green | `#81efc0` | Unassigned in this default; some teams use it for the happy path |

Uncolored = plain logic (transforms, assigns, gateways). Never color for aesthetics; a color that
needs explaining is wrong.

Whatever the assignment, **decide it once and apply it everywhere**. A legend that holds in four
processes and not in the fifth is worse than no legend, because a reader stops trusting it. Green is
the usual flashpoint: leaving the happy path uncolored and coloring only reads, writes and failures
is one coherent choice, and coloring the happy path green is another; mixing them in one tenant is
not.

## Text annotations (the why, never the what)
Attach an annotation only where the canvas cannot explain itself: business rules that look like
bugs, magic values, external constraints (rate limits, batch caps), and deliberate deviations from
the source system. Never restate a shape's name; keep it under ~15 words; budget 2-4 per process -
anything longer or broader belongs in the process Description.

## Groups (labelled phases, no execution semantics)
Groups do not participate in structured-flow analysis, so they are the free way to mark a region.
Use one when several **top-level** shapes form a phase that is not a Scope (e.g. a trigger cluster
plus its routing guards). Never inside a Scope (the Scope already frames), never nested, always
labelled.

## Shape colors (encoding)
Colors are pure DI: `bioc:fill="#hex" color:background-color="#hex"` on the shape's `BPMNShape`
(both attributes, same value), with `xmlns:bioc="http://bpmn.io/schema/bpmn/biocolor/1.0"` and
`xmlns:color="http://www.omg.org/spec/BPMN/non-normative/color/1.0"` declared on `definitions`.
The editor palette: pink `#ffb4de`, purple `#aa8dfa`, blue `#78d8ff`, green `#81efc0`,
orange `#ffbb95`, red `#ff8282`.

## Tags
`Tags` is a free list on the process, used to filter the process list. A widely useful default is
one tag per external system the process touches (e.g. `"Tags": ["CRM", "ERP"]`), reusing existing
tag names rather than inventing near-duplicates. Whatever scheme an organisation picks, it only
pays off if every process follows it.

## Related
[node-naming.md](node-naming.md) ·
[confirmed-shape-parameters.md](confirmed-shape-parameters.md)

## Source of truth
Calibrated against processes arranged by hand in the Frends 6.3 editor and re-exported;
the editor itself accepts any geometry.
