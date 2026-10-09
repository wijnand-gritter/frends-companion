# House standards

An organisation's written standard overrides the convention rules in [rules.md](rules.md). The
platform rules stay in force whatever the standard says.

## Where to find them
1. A path the user gives in the request.
2. `house_standards.md` in the workspace root (from the plugin template). It lists paths or links to
   the standard's documents and, optionally, rule ids to switch off.
3. Neither: review against the Frends baseline in [rules.md](rules.md) and say so in the report.

## How to apply them
1. Read the standard's documents before reviewing.
2. For each convention rule, use the standard's version where it has one. Cite the standard's section
   instead of the rule id's baseline source.
3. Add the standard's own rules as extra manual checks, citing their section numbers.
4. Switch off baseline auto rules the standard contradicts with `--disable`, e.g.
   `--disable NAM-01` where the standard keeps bracketed prefixes, and name the reason in the report.
5. Where the standard contradicts a platform rule, report the platform rule and flag the standard as
   needing a correction.

## house_standards.md format
Free-form. Example:

```
# House standards

Standard: CI-INT-STD-FRD-001 Frends development standards
Location: ~/Documents/Conclusion Integration/Integration Practice/Platforms/Frends/CI-INT-STD-FRD-001 - Development Standards
Disable: none
Error pipeline: Shared - Handle process error, Shared - Notify error events
```
