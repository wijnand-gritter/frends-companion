# Trigger Parameter Fields (special case)

**Category:** trigger · **Baseline:** Frends 6.2

## Purpose
Trigger parameter fields behave differently from ordinary shape fields, and the difference trips
people up. This file is the single place that rule lives; trigger files link here.

## The rule
- Trigger parameter fields are **always treated as Text**, with a twist: **Environment Variables can
  be referenced directly** with `#env.Group.Name` (no Handlebars), and **only those references are
  evaluated** — other Handlebars or C# in the field are left as literal text.
- A separator (such as a space) is required after an `#env` reference.
- **Manual Trigger parameters are the exception:** they evaluate nothing, neither references nor
  code. See [manual.md](manual.md).

## Related
General field-type rules: [../expressions/field-types.md](../expressions/field-types.md).
Reference syntax: [../expressions/reference-syntax.md](../expressions/reference-syntax.md).
