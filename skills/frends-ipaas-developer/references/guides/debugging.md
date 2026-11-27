# Guide: debugging with Process Instances

The [Process Instance](../concepts/process-instance.md) view is the primary debugging surface: each
run, shape by shape, with start time, duration, what executed, and the result.

## Reading Process Instances
- Open **Show Process Instances** from the Process list (or click the Last execution / counts
  columns). Click a shape to inspect its detail.
- Select multiple Processes and use the bulk **Show Process Instances** action to view and filter
  several Processes' executions together — e.g. tracing one Order ID across Processes.
- Filter by time period and state; search promoted result values using SQL wildcards.
- Auto refresh keeps the list near real time; turn it off when reviewing older runs amid heavy
  traffic.
- Via the Platform API: `frends-instances.sh list|details|counts` — see
  [cli_tool_reference.md](cli_tool_reference.md).

## Make runs debuggable in the first place
- **Name shapes meaningfully** — the name is also the `#result[...]` key.
- **Split logic into shapes** instead of one big [Code Task](../shapes/code-task.md); each shape is a
  separately inspectable step.
- **Promote key values** (e.g. an Order ID) so the Instance list is searchable and one business
  entity is traceable across Processes.

## Logging levels and the performance tradeoff
| Level | Records | Use |
| --- | --- | --- |
| Only errors | failed runs only; successful runs leave no Instance detail | production |
| Default | shape results; arrays truncated at 100 elements, text at 10,000 characters | development, test |
| Log everything | parameters and results, no truncation | temporary troubleshooting |

- Set production Agent Groups to **Only errors**. Verbose logging slows Processes and the UI and
  exposes payloads.
- Enable **Log everything** for a set duration so it reverts by itself.
- **Promoted values are logged at every level.** Whatever support needs from a successful
  production run (correlation id, business key, run counts) must be promoted.
- Many promoted values on a high-volume Process can time out the Instance list.
- **"Skip logging result and parameters"** on a shape hides its values from the Instance: use it
  on shapes that carry secrets, personal data or large payloads.

## Changed in 6.4
- Every shape now logs its parameters at the Default level as well as its result, truncated. The
  6.4.0 release notes give 2,000 characters per value and 20 list items. A Process picks this up
  when a new version is saved and deployed. Parameters that carry personal data or large payloads
  now show up where they did not before, so "Skip logging result and parameters" matters on more
  shapes.
- Secret Environment Variables, secret Process Variables and secret Manual Trigger parameters are
  masked in Process logs after a rebuild. Credential headers, cookies and query parameters of HTTP
  and API Trigger requests are masked too: `Authorization`, `Cookie`, `X-Api-Key`, `X-ApiKey`,
  `X-Auth-Token`, `Proxy-Authorization` and the API Policy key, extendable with the Agent setting
  `TriggerHeadersToMask`.
- Step data is always logged to blob storage; the database option is gone. The Platform API's
  Process instance details no longer carry the empty `Steps` list: read `stepDataUri`.
- Validation errors show on the canvas grouped by shape, and compilation errors under the shape
  that caused them.
- A Process that fails before any step runs, for example on a trigger error, now logs the failed
  trigger step to blob storage, so the instance shows why it failed.
- A step whose result throws while it is being logged no longer stays "started" for ever. It is
  logged as finished, with the serialisation error as its value. If a step shows a serialisation
  error, the step itself ran; its result just could not be written to the log. Applies after a
  rebuild.
- Large step values are cut to the logging limits while they are serialised, which makes logging
  them lighter. Applies after a rebuild.

## Source of truth
`https://docs.frends.com/management-and-operations/dashboard-and-monitoring/process-instances.md`
