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

## Changed in 6.3 (API Policy migration)
- API key **header names are configurable per API Policy** - previously fixed to
  `Authorization: Apikey` / `x-apikey` / spec-defined headers. Existing rulesets are migrated.
- A Process whose OpenAPI spec declares OAuth but that matched an API-key ruleset now accepts
  **both** methods after migration (previously OAuth-only). Review policies where that widening
  matters.
- The migration can fail when the OpenAPI spec and the deployed Process disagree - align them
  before upgrading.

## Conventions (Frends best practices collection)
- Name an API after the business capability it exposes, never the backend system behind it.
- Design first: the OpenAPI specification is agreed before the Process is built.
- Deploy an API and its linked Processes together; operate APIs from Test and Production.
- Decide the versioning approach when the API is created: some API properties cannot be changed in
  place afterwards.

## Source of truth
`https://docs.frends.com/frends-development/api-management.md`
