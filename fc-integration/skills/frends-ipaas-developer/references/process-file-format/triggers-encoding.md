# Triggers encoding

`TriggersJson` is an array of typed trigger objects keyed back to the start event id:
```json
[ { "$type": "ManualTrigger", "config": {}, "name": "Manual",
    "id": "StartEvent_1", "shouldNotLogParameters": null } ]
```
Each trigger's `$type` corresponds to the `SelectedTypeId` on its Type 0 start shape.

**Provenance:** all 11 `$type` values and the `config` keys below are **confirmed against real 6.2
exports** — the HTTP API trigger from a production API process, and the other ten from an "All Icons"
palette export (6.2.3.3649). The palette triggers are unconfigured, so the listed keys are those a
**default** trigger carries; a fully configured trigger may include more. Validate specifics against
the tenant `/swagger` or a configured export.

| Trigger | `$type` | Confirmed `config` keys | Reference |
| --- | --- | --- | --- |
| Manual | `ManualTrigger` | (empty; params via `ManualTriggerJson`) | [../triggers/manual.md](../triggers/manual.md) |
| Schedule | `ScheduleTrigger` | `startTime*`, `endTime*`, `recurring`, `repeatDelay*`, `cycleType`, `cycleLength`, `cycleRecurEvery`, `cycleDaysOfWeek`, `cycleMonths`, `cycleDaysString`, `cycleDayRanks`, `monthlyCycleType`, `season*Date`, `limitToOneConcurrentExecution`, `timeZone` | [../triggers/schedule.md](../triggers/schedule.md) |
| File | `FileWatchTrigger` | `version`, `dirToWatch`, `fileMask`, `includeSubDirectories`, `maxFilesPerBatch`, `pollIntervalSeconds` | [../triggers/file.md](../triggers/file.md) |
| Conditional | `ConditionalTrigger` | `pollingInterval`, `processGuid`, `limitToOneConcurrentExecution`, `parameters` | [../triggers/conditional.md](../triggers/conditional.md) |
| HTTP | `HttpTrigger` | `routeTemplate`, `allowedSchemes`, `auth`, `corsEnabled`, `allowedOrigins`, `httpMethod`, `isPrivate` | [../triggers/http.md](../triggers/http.md) |
| API | `HttpApiTrigger` | `routeTemplate`, `httpMethod`, `isPrivate`, `corsEnabled`, `allowedOrigins`, `allowedSchemes`, `references`, `openApiDocument` | [../triggers/api.md](../triggers/api.md) |
| AMQP / Queue | `QueueTrigger` | (empty by default) | [../triggers/amqp.md](../triggers/amqp.md) |
| Service Bus | `ServiceBusTrigger` | `queueName`, `connectionString`, `maxConcurrentMessages`, `messagePrefetchCount`, `consumeMessageImmediately`, `reply`, `replyErrors`, `replyTo`, `retryMessageProcessingIfExceptionThrown` | [../triggers/service-bus.md](../triggers/service-bus.md) |
| RabbitMQ | `RabbitMQTrigger` | `maxConcurrentMessages` (more when configured) | [../triggers/rabbitmq.md](../triggers/rabbitmq.md) |
| Azure Event Hub | `AzureEventHubTrigger` | `eventHubAuthSettings`, `eventHubName`, `consumerGroupName`, `eventBatchSize`, `encoding`, `passDataAsBase64ByteArray`, `updateCheckpointImmediately`, `maxConcurrentProcesses`, `loadBalancingStrategy`, `blobCheckPointSettings` | [../triggers/azure-event-hub.md](../triggers/azure-event-hub.md) |
| TCP | `TcpTrigger` | `dataMode`, `encoding`, `idleTimeoutSeconds`, `connectionIdBuilder`, `listenPort`, `listenAddress`, `maxConnections`, `terminationEvent`, `terminationHexString`, `allowedIps`, `autoAppendTermSeq` | [../triggers/tcp.md](../triggers/tcp.md) |

The full HTTP API `config` (with `references` and embedded `openApiDocument`) is shown in
[confirmed-shape-parameters.md](confirmed-shape-parameters.md). `Manual` and `HttpApi` were already
confirmed earlier; the other nine are newly confirmed from the palette export.
