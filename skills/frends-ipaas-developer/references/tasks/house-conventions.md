# Task house conventions

Category: tasks · Conventions, overridden by the organisation's standard named in
`house_standards.md`.

Where Conclusion's rules for custom Tasks differ from, or add to, the official template conventions.

## Identity

| Element | Rule | Example |
| --- | --- | --- |
| Party | `Conclusion` | `Conclusion.AFAS.GetConnector` |
| System segment | the vendor's casing for the system | `AFAS`, `HubSpot` |
| Action segment | the domain's own word for the operation | `GetConnector`, `UpdateConnector` |
| Repository | one per system, on the organisation's GitLab | the AFAS Tasks repository |

`Frends.*` is reserved for the official catalogue. Existing packages under that prefix are renamed
at their next major version:

| Package | Target |
| --- | --- |
| `Frends.AFAS.GetConnector` | `Conclusion.AFAS.GetConnector` |
| `Frends.AFAS.UpdateConnector` | `Conclusion.AFAS.UpdateConnector` |
| `Frends.Conclusion.ErrorHandling` | `Conclusion.<System>.<Action>` per Task method; a package with several Task methods is split or recorded as a deviation |

A rename is a new package id: Processes move to it like a major version, with a CHANGELOG entry and
a `migration.json` entry in the new package.

## Contract alignment
New Tasks follow [anatomy.md](anatomy.md) exactly. For the AFAS Tasks at their next major version:

| AFAS 1.x | Target |
| --- | --- |
| `Options.ThrowExceptionOnErrorResponse`, default `false` | `Options.ThrowErrorOnFailure`, default `true`, plus `ErrorMessageOnFailure` |
| `Error { Message, IsBusinessError, ErrorNumber, ProfitLogReference, Raw }` | `Error { Message, AdditionalInfo }` with a typed `AdditionalInfo { IsBusinessError, ErrorNumber, ProfitLogReference }`; no raw body by default |

The domain rule stays: AFAS returns business validation errors with HTTP 500 and an
`externalMessage`, so `IsBusinessError` comes from `externalMessage`, never from the status code.

## CI and feed

| Stage | GitLab CI |
| --- | --- |
| Test | every push: build with warnings as errors, `dotnet test` with coverage, 80% gate |
| Pack | on main |
| Publish | on a version tag, to the organisation's NuGet feed named in `house_standards.md` |
| Guard | publish refused without a bumped `<Version>` and a CHANGELOG entry |

Remove the template's GitHub workflows; they depend on Frends' internal feeds and secrets.

## Licence
Per repository: MIT for Tasks meant for reuse outside Conclusion, a proprietary licence file for
customer-specific Tasks. Ask when the repository does not state it.

## Sources
- Decisions recorded in the Frends Companion project
- [anatomy.md](anatomy.md), [testing.md](testing.md)
