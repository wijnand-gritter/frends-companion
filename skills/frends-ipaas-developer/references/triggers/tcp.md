# TCP Trigger

**Category:** trigger · **Baseline:** Frends 6.2

## Purpose
Listens for raw TCP connections coming to Frends and starts a Process per connection/message.

## Configuration (confirmed keys)
`listenAddress`, `listenPort`, `dataMode`, `encoding`, `idleTimeoutSeconds`, `connectionIdBuilder`,
`maxConnections`, `terminationEvent`, `terminationHexString`, `autoAppendTermSeq`, `allowedIps`.

## Serialization
JSON `Type` 0, `SelectedTypeId: "TcpTrigger"`. Confirmed `config` keys as listed. See
[../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md).

## Source of truth
`https://docs.frends.com/reference/triggers/tcp-trigger.md`
