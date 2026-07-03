# API Management

**Category:** concept · **Baseline:** Frends 6.2

## Purpose
API management is built into Frends and always included. Provide an OpenAPI specification, link a
[Process](process.md) to each endpoint, and the Process becomes the implementation behind the API,
secured through the platform.

## Key facts
- Pair with the [API / HTTP Trigger](../triggers/api.md), which exposes the request as
  `#trigger.data.*`.
- API Policies handle authentication (API keys, OAuth, Basic), logging, and throttling per endpoint.
- The embedded OpenAPI contract is stored in the trigger config (`openApiDocument`); see
  [../process-file-format/confirmed-shape-parameters.md](../process-file-format/confirmed-shape-parameters.md).

## Source of truth
`https://docs.frends.com/frends-development/api-management.md`
