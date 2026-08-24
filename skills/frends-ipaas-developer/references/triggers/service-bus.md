# Service Bus Trigger

**Category:** trigger · **Baseline:** Frends 6.2

## Purpose
Listens for Azure Service Bus messages and starts a Process per message.

## Configuration (confirmed keys)
`queueName`, `connectionString`, `maxConcurrentMessages`, `messagePrefetchCount`,
`consumeMessageImmediately`, `reply`, `replyErrors`, `replyTo`,
`retryMessageProcessingIfExceptionThrown`. Keep the `connectionString` in an
[Environment Variable](../concepts/environment-variables.md), not inline.

## Serialization
JSON `Type` 0, `SelectedTypeId: "ServiceBusTrigger"`. Confirmed `config` keys as listed. See
[../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md).

## Source of truth
`https://docs.frends.com/reference/triggers/service-bus-trigger.md`
