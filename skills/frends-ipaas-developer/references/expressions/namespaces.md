# Available namespaces

**Baseline:** Frends 6.2 (editor C#)

Available directly (no fully qualified name) in Frends C# expressions and Code Tasks:
`System`, `System.Net`, `System.Security`, `System.Xml`, `System.Xml.Linq`, `System.Data`,
`System.Threading.Tasks`, `System.Dynamic`, `System.Linq`, `System.Collections.Generic`,
`System.Reflection`, `Newtonsoft.Json`, `Newtonsoft.Json.Linq`.

So `new JArray()` and `List<T>()` work without qualification.

Available only with the **fully qualified name** written out: functions from
`Microsoft.CodeAnalysis`, `Microsoft.CSharp`, and the broad `mscorlib` namespaces (`System.IO`,
`System.Text`, `System.Security.Cryptography`, `System.Globalization`, and many more). A common
case: encoding bytes to text needs the FQDN, e.g.
`System.Text.Encoding.UTF8.GetString(#var.binaryDataBytes)`.

These limits apply to C# **in the Process Editor**. **Custom Tasks may use any other libraries and
namespaces** — which is exactly why you build one when the editor's set is not enough (see
[code-tasks.md](code-tasks.md) and [../tasks/authoring.md](../tasks/authoring.md)).

## Source of truth
`https://docs.frends.com/reference/process-development/c-in-frends/available-namespaces.md`
