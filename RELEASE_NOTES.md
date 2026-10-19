# CouchBase 0.0.5

The first standalone release of the CouchBase Crystal shard carries forward
all driver features through CryBase 0.0.5. Applications now use
`require "couchbase"` and the top-level `CouchBase` namespace.

## Connections and transport

- Connection strings support `couchbase://`, `couchbases://`, and HTTP(S)
  Management URLs, multiple seed hosts, per-host ports, credentials, bucket
  paths, and TLS/network options.
- Service and endpoint types expose plaintext and TLS ports. The cluster-level
  `Client` enumerates service endpoints and probes TCP reachability.
- Shared TCP, TLS, and HTTP helpers provide connect/read/write timeouts,
  certificate verification, hostname overrides, and custom OpenSSL contexts.

## Key Value service

- Binary protocol negotiation, SASL PLAIN authentication, and bucket selection
  over plaintext or TLS sockets.
- Document `get`, `set`, and `delete`; expiration through `touch` and atomic
  get-and-touch; `increment` and `decrement` counters.
- Typed JSON storage and `get_as` for `JSON::Serializable` models.
- Fixed-size `KV::Pool` with connection checkout and pooled operation helpers;
  `KV::Cluster` provides seed failover through one active pool.
- Named scope and collection contexts, collection manifest lookup, and
  collection-aware key encoding. Clients, pools, and clusters support global
  bucket/scope/collection defaults and chainable collection helpers.
- Management bucket-config discovery selects the bucket's `numVBuckets`,
  fixing `NotMyVbucket` errors for buckets with counts such as 64. Explicit
  vbucket counts and discovery opt-out are supported; unavailable config falls
  back to 1024 vbuckets.

## Query service

- Authenticated N1QL/SQL++ over HTTP/HTTPS with positional and named parameters,
  readonly requests, scan consistency, rows, metadata, warnings, and errors.
- SQL++ statements support reads and mutations such as `INSERT`, `UPSERT`,
  `UPDATE`, and `DELETE`.
- Query-node discovery from Management topology, alternate network selection,
  explicit topology refresh, static seed fallback, and endpoint failover.
- Explicit prepare/execute APIs, `adhoc: false` plan caching, and one reprepare
  attempt when a cached plan is missing. Cache keys include query context.
- Reusable HTTP connections and endpoint clients across repeated requests.
- Named bucket/scope/namespace context arguments, chainable bucket/scope
  helpers, connection-level defaults, and bucket paths in connection strings.
- Typed `query_as`, row iteration, streamed `query_each`/`query_each_as`, and
  single-use `Query::Cursor` with typed row consumption.
- Per-query `RetryPolicy` values and a `no_retry` default. The policy API is
  available; automatic retry/backoff execution remains future work.

## Examples, tests, and documentation

- Ten runnable examples cover endpoint probes, KV operations and pooling,
  seed failover, expiration, Query basics, prepared statements, cursors,
  mutations, and retry policy arguments, with shared configuration and models.
- Unit specs and real Couchbase integration specs are migrated to `CouchBase`.
  CI retains Community 7.6/8.0 integration jobs, Enterprise 7.6/8.0 Query TLS
  jobs, and Community Query TLS coverage through an nginx proxy.
- Installation, quick-start, KV, Query, and glossary manuals accompany
  generated API documentation. Formatting, Ameba, coverage tooling, and local
  commit hooks are retained.
- Ameba 1.7 supports dependency installation with Crystal 1.21.
- Coverage CI uses Ubuntu 24.04 with a cached kcov 43 source build for
  compatibility with the current Crystal toolchain.

## Migration

Use the `couchbase` dependency from `shardscry/couchbase`. Replace
`require "crybase"` with `require "couchbase"` and `CryBase::CouchBase` with
`CouchBase`. Shared namespaces become `CouchBase::Connectivity` and
`CouchBase::Interfaces`. The version remains `0.0.5`.

## Current limits

KV clusters provide seed failover rather than node/vbucket-map routing. Query
connection pooling, general automatic retry/reconnect execution, durability,
observe, and CAS helpers are not implemented. Search, Analytics, Index,
Eventing, Views, and full Management protocol clients are not implemented.
`CouchBase::Client#connect` probes TCP only; use service-specific clients for
authenticated protocol operations.
