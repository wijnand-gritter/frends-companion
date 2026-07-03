# RabbitMQ Trigger

**Category:** trigger · **Baseline:** Frends 6.2

## Purpose
Consumes messages from RabbitMQ — an alternative to Service Bus and AMQP queues.

## Configuration
`maxConcurrentMessages` is confirmed; the palette default carried only that key, so the rest of the
configured set (connection, queue) isn't captured here — confirm against a configured export or docs.

## Serialization
JSON `Type` 0, `SelectedTypeId: "RabbitMQTrigger"`. Confirmed `$type`; only `maxConcurrentMessages`
observed by default. See
[../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md).

## Source of truth
`https://docs.frends.com/reference/triggers/rabbitmq-trigger.md`
