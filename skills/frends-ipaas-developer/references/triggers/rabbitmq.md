# RabbitMQ Trigger

**Category:** trigger · **Baseline:** Frends 6.2 (6.3 additions noted below; configured key set confirmed on 6.3.2.5468)

## Purpose
Consumes messages from RabbitMQ — an alternative to Service Bus and AMQP queues.

## Configuration
- `connectionString`: an AMQP URI starting with `amqp://` or `amqps://`.
- `queueName`: the queue to consume; it cannot start with `frends_`.
- `maxConcurrentMessages`: messages processed at once, default 1.
- `reply`, `replyErrors`, `replyTo`: send a reply, send an error reply, the reply queue address.
- `retryMessageProcessingIfExceptionThrown`: retry the message when the Process throws.
- `shouldNotLogParameters`: keep the trigger parameters out of the Process Instance log.

Validation rules on the URI and queue name come from the MCP builder's schema on 6.3.2.

## New in 6.3: client certificate authentication
The trigger accepts a client certificate for mutual TLS: by thumbprint from the certificate store,
or from a PFX/P12 or PEM/CRT file, with an optional password (PFX/P12) or separate key file (PEM).

From 6.3.1, "Use client certificate" without certificate details is a validation error. The trigger
retries when RabbitMQ is unavailable at Agent startup or resume, shows an error state when the
connection drops and resumes consuming after the Agent is paused and resumed.

## Serialization
BPMN `startEvent`; JSON `Type` 0, `SelectedTypeId: "RabbitMQTrigger"`; `TriggersJson`
`$type: "RabbitMQTrigger"`. Confirmed against a 6.3.2.5468 export with PEM client certificate
authentication
([../process-file-format/examples/mcp_rabbitmq_inclusive_export_6.3.json](../process-file-format/examples/mcp_rabbitmq_inclusive_export_6.3.json)).
The start shape's `Parameters` and the trigger `config` carry the same keys, all as plain JSON
values (no `{mode, value}` leaves):

```json
{ "$type": "RabbitMQTrigger",
  "config": {
    "connectionString": "amqps://rabbitmq.example.invalid:5671/",
    "queueName": "companion-test",
    "maxConcurrentMessages": 2,
    "retryMessageProcessingIfExceptionThrown": false,
    "reply": false,
    "replyErrors": false,
    "shouldNotLogParameters": true,
    "useClientCertificate": true,
    "clientCertificateType": "pem/crt",
    "clientCertificateThumbprintOrPath": "/placeholder/certs/companion-test-client.pem",
    "clientCertificateKeyPath": "/placeholder/certs/companion-test-client.key",
    "skipServerCertificateValidation": false
  },
  "name": "Receive companion test message", "id": "RabbitTrigger",
  "shouldNotLogParameters": false }
```

Client certificate keys:

| Key | Meaning | Status |
| --- | --- | --- |
| `useClientCertificate` | `true` turns certificate authentication on; the MCP builder sets it when a certificate type is given | confirmed |
| `clientCertificateType` | `"Thumbprint"`, `"pfx/p12"` or `"pem/crt"` | `"pem/crt"` confirmed; the other two values come from the MCP builder's schema |
| `clientCertificateThumbprintOrPath` | thumbprint (Windows store) or file path | confirmed |
| `clientCertificateKeyPath` | separate private key file for PEM | confirmed |
| `skipServerCertificateValidation` | skip server certificate checks, development only | confirmed |
| `clientCertificatePassword` | password for PFX/P12 | key name from the MCP builder's schema; not in the export, which used PEM |
| `clientCertificateStore` | `"CurrentUser"` or `"LocalMachine"` for a thumbprint | key name from the MCP builder's schema; not in the export |

- `replyTo` is omitted when unset; the export had no reply queue, so its value shape is not shown.
- `shouldNotLogParameters` set through the MCP builder lands inside `config`, while the trigger
  object's own `shouldNotLogParameters` stayed `false`. Which of the two the runtime reads is not
  settled by the export; set both when the parameters must stay out of the log.
- Never put a certificate password into a generated file or an MCP tool argument; a person sets it
  in the Control Panel. Whether this field accepts an `#env` reference is not confirmed.

## Source of truth
`https://docs.frends.com/reference/triggers/rabbitmq-trigger.md`
