# Triggers — index

The start condition of a Process. One file per type, plus the shared field-behavior note. All
`$type`/`config` keys are confirmed against real 6.2 exports (see
[../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md)).

| File | `SelectedTypeId` | What / when to read |
| --- | --- | --- |
| [manual.md](manual.md) | `ManualTrigger` | On-demand "Run once"; optional prompted parameters. |
| [schedule.md](schedule.md) | `ScheduleTrigger` | Time-based (cron-like). |
| [file.md](file.md) | `FileWatchTrigger` | File event (e.g. SFTP/folder watch). |
| [conditional.md](conditional.md) | `ConditionalTrigger` | Polls a condition, often via a Subprocess. |
| [http.md](http.md) | `HttpTrigger` | Simple HTTP endpoint / webhook. |
| [api.md](api.md) | `HttpApiTrigger` | Full OpenAPI-backed, API-managed endpoint. |
| [amqp.md](amqp.md) | `QueueTrigger` | AMQP message queue. |
| [service-bus.md](service-bus.md) | `ServiceBusTrigger` | Azure Service Bus messages. |
| [rabbitmq.md](rabbitmq.md) | `RabbitMQTrigger` | RabbitMQ messages. |
| [azure-event-hub.md](azure-event-hub.md) | `AzureEventHubTrigger` | Azure Event Hub events. |
| [tcp.md](tcp.md) | `TcpTrigger` | Raw TCP connections. |
| [parameter-fields.md](parameter-fields.md) | — | **Read this** for the special Text/`#env` field behavior. |

To add a trigger: copy [../_TEMPLATE.md](../_TEMPLATE.md) here, add a row above, record its
`$type`/`config` in [../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md),
add a router line to [../../SKILL.md](../../SKILL.md).
