# .NET and C# versions

**Baseline:** Frends 6.2

- Latest Frends: **.NET 8.0**, C# language features up to **C# 12**.
- Some older versions: **.NET 6.0**, up to **C# 10**.
- Legacy: **.NET Framework 4.7.1** and **.NET Standard 2.0** (the latter for migrating from the
  legacy Agent to the cross-platform Agent). On these, C# is limited to **7.3**.

Target **.NET 8 / C# 12** unless supporting a legacy environment. The Process file records this as
`TargetFramework` (`net8.0`) and `FrendsVersion`; see
[../process-file-format/proprietary-json.md](../process-file-format/proprietary-json.md).

## Source of truth
`https://docs.frends.com/reference/process-development/c-in-frends.md`
