# Connection / Endpoint Registry

List the connections, APIs, and Environment Variables you reuse so the agent can find and re-use them instead of re-discovering each time.

Format is free-form — describe each entry and include whatever helps the agent identify it: a Control Panel link, Process GUIDs, Agent Group / Environment IDs, endpoint paths, or notes on when to use it.

## Example formats

### Salesforce — production
Environment Variable group: `Salesforce` (id 42). Holds `Salesforce.Username`, `Salesforce.Token`.
Use the HTTP Request Task with `#env.Salesforce.*` for REST calls.

### Orders API (internal)
API trigger Process "Orders API" — guid `00000000-0000-0000-0000-000000000000`.
Endpoints: POST /orders, GET /orders/{id}. Deployed to Test Agent Group id 7, Prod Agent Group id 9.

### PostgreSQL — customer orders
Environment Variable group: `OrdersDb` (id 18) → `OrdersDb.ConnectionString` (Secret).
Use the SQL Task; connection string via `#env.OrdersDb.ConnectionString`.
