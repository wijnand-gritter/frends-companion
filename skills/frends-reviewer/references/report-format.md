# Report format

One report per review. Findings first, most severe first.

```
# Frends review: <Process or repository>

Standard: <house standard and version, or "Frends baseline">
Scope: <files reviewed>, <auto + manual | auto only>
Verdict: <blocked | changes required | accepted with remarks | accepted>

## Findings
| Rule | Severity | Where | Finding | Fix |
| --- | --- | --- | --- | --- |

## Manual rules not assessable
| Rule | Missing input |
| --- | --- |

## Not reviewed
<anything out of scope, e.g. tenant log level settings>
```

## Verdict
| Verdict | When |
| --- | --- |
| blocked | any blocker |
| changes required | any major |
| accepted with remarks | minors or infos only |
| accepted | no findings |

## Writing the findings
- Cells are labels: shape name and id, a short finding, a concrete fix.
- One finding per rule per location. Merge repeats of the same rule in one row with a count.
- A manual finding cites what was read: the spec section, the shape, the setting.
- A rule that cannot be assessed goes under "Manual rules not assessable", never silently skipped.
- Cite the house standard's section where one applies; otherwise the rule id.
