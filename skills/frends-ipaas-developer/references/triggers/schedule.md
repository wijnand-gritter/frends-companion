# Schedule Trigger

**Category:** trigger · **Baseline:** Frends 6.3 (config confirmed against configured production-tenant exports)

## Purpose
Runs a Process repeatedly on a time schedule. A process may carry **multiple Schedule
Triggers** (the one-trigger limit applies to [API Triggers](api.md) only).

## Configuration (confirmed, full field set)
```json
{
  "startTimeMinute": "00", "startTimeHour": "00",
  "endTimeMinute": "00", "endTimeHour": "00",
  "endTime": "00:00", "startTime": "00:00",
  "recurring": true,
  "repeatDelay": 60, "repeatDelayType": 60, "repeatDelaySeconds": 3600,
  "limitToOneConcurrentExecution": true,
  "cycleRecurEvery": 1, "cycleType": "Daily", "cycleLength": 1,
  "seasonStartDate": "2026-08-16", "seasonEndDate": null,
  "cycleDaysOfWeek": "None", "cycleMonths": "None",
  "cycleDaysString": "", "cycleDayRanks": "None", "monthlyCycleType": "OnDays",
  "timeZone": "W. Europe Standard Time",
  "datesToExclude": "", "openOnlyOnDates": ""
}
```

Semantics established from configured exports:

- **`repeatDelayType` is a unit multiplier** (1 = seconds, 60 = minutes) and
  `repeatDelaySeconds` is the precomputed product `repeatDelay * repeatDelayType`
  (e.g. 60 x 60 = 3600 for hourly, 10 x 1 = 10 for every ten seconds). Emit all three
  consistently.
- **`recurring: true`** repeats every `repeatDelaySeconds` within the daily
  `startTime`..`endTime` window (00:00..00:00 = all day); **`recurring: false`** fires
  once per cycle at `startTime` (e.g. daily at 02:00 with `startTime: "02:00"`,
  `startTimeHour: "02"`).
- `cycleType` `Daily`/`Weekly` (+ monthly variants); `cycleRecurEvery` = every N cycles;
  `cycleDaysOfWeek` is a comma list (`"Saturday,Friday,Tuesday"`) or `"None"`.
- **`timeZone` is a Windows time-zone id** (`W. Europe Standard Time`), not IANA.
- `seasonStartDate` defaults to the creation date; `datesToExclude` / `openOnlyOnDates`
  hold date strings or empty.
- `limitToOneConcurrentExecution: true` = single-instance (no overlapping runs).

## Serialization
JSON `Type` 0, `SelectedTypeId: "ScheduleTrigger"`. The config appears **identically in
the trigger's `ElementParameters` entry and in `TriggersJson`** - keep the two copies in
sync, like the API trigger. Values are plain (no `{mode,value}` leaves). See
[../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md).

## Expressions and references
Trigger parameter fields are Text with the `#env` exception; see
[parameter-fields.md](parameter-fields.md).

## Gotchas
- A Schedule that must not overlap itself is set to single instance.
- With "Repeat" enabled the interval must be non-zero; an empty interval fails the trigger with
  `DivideByZeroException`.

## Source of truth
`https://docs.frends.com/reference/triggers/schedule-trigger.md`; config confirmed against
Frends 6.3 exports of configured schedules (daily/recurring and weekly variants).
