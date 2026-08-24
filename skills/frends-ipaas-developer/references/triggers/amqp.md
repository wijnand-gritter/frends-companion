# AMQP Trigger

**Category:** trigger · **Baseline:** Frends 6.2

## Purpose
Starts a Process from messages on an AMQP message queue — useful for ordered, queue-driven
processing.

## Configuration
Queue connection and consumption settings. The palette export carries a default (empty) `config`, so
the configured key set isn't captured here — confirm against a configured export or the docs.

## Serialization
JSON `Type` 0, `SelectedTypeId: "QueueTrigger"` (display name "Queue"). Confirmed `$type` =
`QueueTrigger`; `config` keys not yet observed (default was empty). See
[../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md).

## Source of truth
`https://docs.frends.com/reference/triggers/amqp-trigger.md`
