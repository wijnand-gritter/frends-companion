# Manual Trigger

**Category:** trigger · **Baseline:** Frends 6.2

## Purpose
Starts a Process on demand ("Run once"). Can define parameters that are prompted at run time.

## Configuration
- Optional named parameters (e.g. a `TextParameter` of `System.String`). If a Process has no Manual
  Trigger, an implicit parameterless Manual Trigger is used for "Run once".
- A Process expecting [API Trigger](api.md) values will likely fail under Run once, because
  those values cannot be supplied manually.

## Expressions and references
Manual Trigger **parameter fields evaluate nothing** — neither `#` references nor C#. See
[parameter-fields.md](parameter-fields.md). Downstream shapes read the supplied values via
`#trigger`.

## Serialization
JSON `Type` 0, `SelectedTypeId: "ManualTrigger"`. The start entry holds
`manualTriggerDefaultValue-0`; `ManualTriggerJson` describes the parameter's type and `TriggersJson`
`config` carries the default. See
[../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md).

## Source of truth
`https://docs.frends.com/reference/triggers/manual-trigger.md`
