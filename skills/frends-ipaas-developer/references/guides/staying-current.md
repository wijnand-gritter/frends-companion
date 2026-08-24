# Guide: staying current

This skill snapshots the durable core of Frends 6.2. For version-specific behavior, exact Task
parameters, new features, or anything not covered in the references, fetch the live docs — don't
guess at attribute names, Task parameters, trigger configs, or UI labels.

## How to query the docs
- Any docs page has a Markdown version: append `.md` to the path, e.g.
  `https://docs.frends.com/reference/process-development/c-in-frends.md`.
- Any docs page answers natural-language questions via a query parameter:
  `GET https://docs.frends.com/<path>.md?ask=<your specific question>`. Ask a specific,
  self-contained question.
- The full documentation as one LLM-readable file: `https://docs.frends.com/llms-full.txt`.
- The page index: `https://docs.frends.com/sitemap.md`.

## Source code as ground truth
Task source (to confirm exact parameters, enum members, and result objects) is open source under the
`FrendsPlatform` GitHub organization. The custom Task template is
`github.com/FrendsPlatform/FrendsTaskTemplate`. The Platform API surface is on the tenant at
`https://<tenant>.frendsapp.com/swagger`.

## When you rely on a fetched detail
Tell the developer it came from the live docs and note the version sensitivity if relevant. When
unsure of an exact name or label, say so and fetch rather than inventing it.
