# Schedule Trigger

**Category:** trigger · **Baseline:** Frends 6.2

## Purpose
Runs a Process repeatedly on a time schedule (cron-like).

## Configuration
Schedule cadence (interval/cron-style) and activation window. Confirm the exact `config` field set
against the live docs or a real export — it is not captured in the bundled examples.

## Expressions and references
Trigger parameter fields are Text with the `#env` exception; see
[parameter-fields.md](parameter-fields.md).

## Serialization
JSON `Type` 0, `SelectedTypeId: "ScheduleTrigger"`. **Confirmed** 6.2 `config` keys include
`startTime*`/`endTime*`, `recurring`, `repeatDelay*`/`repeatDelayType`, `cycleType`, `cycleLength`,
`cycleRecurEvery`, `cycleDaysOfWeek`, `cycleMonths`, `cycleDaysString`, `cycleDayRanks`,
`monthlyCycleType`, `season*Date`, `limitToOneConcurrentExecution`, and `timeZone`. See
[../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md).

## Source of truth
`https://docs.frends.com/reference/triggers/schedule-trigger.md`
