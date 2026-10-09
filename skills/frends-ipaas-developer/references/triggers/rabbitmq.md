# RabbitMQ Trigger

**Category:** trigger · **Baseline:** Frends 6.2 (6.3 additions noted below)

## Purpose
Consumes messages from RabbitMQ — an alternative to Service Bus and AMQP queues.

## Configuration
`maxConcurrentMessages` is confirmed; the palette default carried only that key, so the rest of the
configured set (connection, queue) isn't captured here — confirm against a configured export or docs.

## New in 6.3: client certificate authentication
The trigger configuration accepts a client certificate (PEM or PFX) with an optional
passphrase, plus TriggerInput parameters for referencing certificates from the certificate
store (mutual TLS). **Serialization of these keys is not confirmed** - harvest a configured
export before generating them.

From 6.3.1, "Use client certificate" without certificate details is a validation error. The trigger
retries when RabbitMQ is unavailable at Agent startup or resume, shows an error state when the
connection drops and resumes consuming after the Agent is paused and resumed.

## Serialization
JSON `Type` 0, `SelectedTypeId: "RabbitMQTrigger"`. Confirmed `$type`; only `maxConcurrentMessages`
observed by default. See
[../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md).

## Source of truth
`https://docs.frends.com/reference/triggers/rabbitmq-trigger.md`
