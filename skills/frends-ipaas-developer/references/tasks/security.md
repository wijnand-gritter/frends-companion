# Task security checklist

Category: tasks · Baseline: Frends 6.3

A custom Task runs inside the Agent with the Agent's privileges and is reused across Processes. Run
this checklist before a Task counts as done and in every review. OWASP Top 10 categories in brackets.

## Secrets and configuration (A02, A05)
- No connection strings, keys, tokens, passwords, certificates or tenant URLs in source, csproj,
  tests, samples or comments.
- Secrets arrive as `Connection` parameters, supplied in the Process from secret Environment
  Variables; the Task never reads a config file or environment variable for credentials.
- Secret parameters carry `[PasswordPropertyText]`.
- No secret in the Result, exception messages or logs, `Error.AdditionalInfo` included.

## Injection (A03)
- Parameterised SQL; no input concatenated or interpolated into a query.
- No shell commands; where unavoidable, an argument list, never a concatenated command line.
- LDAP, XPath and NoSQL queries escaped or parameterised.
- XML parsing with `DtdProcessing = DtdProcessing.Prohibit` and `XmlResolver = null`.
- No `TypeNameHandling.All`, no `BinaryFormatter`.

## Network (A10)
- A caller-supplied URL is validated or allow-listed unless the Task is a general HTTP client.
- TLS validation is never disabled; a private CA gets an explicit certificate or thumbprint
  parameter.
- Redirects followed only where intended, never blindly across hosts.
- A timeout on every outbound call.

## Access (A01)
- The narrowest scope the operation needs, documented in the README.
- File paths canonicalised; traversal outside the intended directory rejected.

## Cryptography (A02)
- Platform primitives only; no MD5 or SHA-1 for security, no ECB, no hard-coded keys or IVs.
- `RandomNumberGenerator` for security randomness.

## Dependencies (A06, A08)
- No known vulnerabilities, or documented and accepted.
- Licences verified: MIT, Apache 2.0, BSD.
- Third-party CI workflows and actions pinned to a commit SHA.

## Logging (A09)
- `Error.Message` says what failed; `AdditionalInfo` carries identifiers, status codes, failed items.
- No payload bodies or personal data in results or logs by default; verbose diagnostics only behind
  an opt-in Options flag.
- Original exceptions kept as inner exceptions.

## Personal data
- Only the fields the purpose needs; field selection exposed where the source supports it.
- No personal data in fixtures, `<example>` blocks, README or CHANGELOG.
- Temporary files removed, on the failure path too.

## AI Tasks
- Model, provider and version explicit and configurable.
- Inputs and outputs traceable enough to reconstruct a Process Instance.
- README states that output is model-generated and can be wrong.
- No irrevocable decision about a person without a human step in the calling Process.

## Reliability
- `CancellationToken` honoured throughout.
- `IDisposable` resources disposed on success and failure.
- One reused `HttpClient`, never one per call in a loop.
- Idempotency considered: shape-level retry repeats the whole Task on any exception, with
  exponential backoff (500 ms × 2^n), and cannot filter by exception type.

## Sources
- `FrendsTaskSkills/frends-task-creator/references/security-checklist.md` (MIT)
- `https://docs.frends.com/guides/development/how-to-handle-errors-in-frends-processes.md`: retry
  backoff is exponential; the FrendsTaskSkills checklist calls it a fixed delay
