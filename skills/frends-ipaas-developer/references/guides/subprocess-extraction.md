# When to extract a Subprocess

**Category:** guide · **Baseline:** Frends 6.3

## Purpose
The advisory checklist for deciding whether a piece of a flow should become a
[Subprocess](../concepts/subprocess.md). Give this feedback **before** building, when a design
review shows a candidate chunk.

## Extract when at least one holds
1. **Reuse:** two or more processes need it (the shared error handler is the canonical case).
2. **Own cadence:** the piece changes at a different rate and deserves its own version history.
3. **Scale:** the parent exceeds roughly 40-50 execution shapes or three nesting levels, and a
   coherent chunk with a **narrow interface** can leave.
4. **Ownership / secrets:** a different team maintains it, or it needs a different secret surface.
5. **Test isolation:** the piece needs its own manual-run harness.

## Keep it inline when
- It has a single caller and the motive is tidiness - Scopes and Groups are the lighter tools.
- The chunk shares many `#var`s with the parent: a wide parameter interface is a smell that the
  boundary is wrong.

## The Frends tax (state it when advising)
A Subprocess is an extra deployable with a **deploy-before-parent prerequisite** (see
[deployment.md](deployment.md)) and GUID pinning in the caller's `LinkedSubProcess`. One more hop
in debugging, one more thing on the release checklist.

## Related
[../shapes/call-subprocess.md](../shapes/call-subprocess.md) ·
[../shapes/scope-and-catch.md](../shapes/scope-and-catch.md) ·
[../process-file-format/canvas-layout-conventions.md](../process-file-format/canvas-layout-conventions.md)
