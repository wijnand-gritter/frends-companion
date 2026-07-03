# Azure Event Hub Trigger

**Category:** trigger · **Baseline:** Frends 6.2

## Purpose
Listens to messages from Azure Event Hub and starts a Process per event/batch.

## Configuration (confirmed keys)
`eventHubAuthSettings`, `eventHubName`, `consumerGroupName`, `eventBatchSize`, `encoding`,
`passDataAsBase64ByteArray`, `updateCheckpointImmediately`, `maxConcurrentProcesses`,
`loadBalancingStrategy`, `blobCheckPointSettings`. Keep auth/connection settings in
[Environment Variables](../concepts/environment-variables.md).

## Serialization
JSON `Type` 0, `SelectedTypeId: "AzureEventHubTrigger"`. Confirmed `config` keys as listed. See
[../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md).

## Source of truth
`https://docs.frends.com/reference/triggers/azure-event-hub-trigger.md`
