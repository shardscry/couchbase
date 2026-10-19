# CouchBase

[![Crystal](https://img.shields.io/badge/Crystal-1.20%2B-000000?logo=crystal&logoColor=white)](https://crystal-lang.org/)
[![Couchbase KV](https://img.shields.io/badge/Couchbase-KV%20Client-EA2328?logo=couchbase&logoColor=white)](https://www.couchbase.com/)
[![Couchbase Query](https://img.shields.io/badge/Couchbase-Query%20Client-EA2328?logo=couchbase&logoColor=white)](https://www.couchbase.com/)

Standalone Crystal client for Couchbase KV and N1QL/SQL++ Query services.

CouchBase currently covers:
1. Couchbase endpoint discovery
2. KV binary protocol with bucket vbucket-count discovery
3. Query HTTP service

Not implemented:
1. Search
2. Analytics
3. Index
4. Eventing
5. Views

## Installation

```yaml
dependencies:
  couchbase:
    github: shardscry/couchbase
    version: ~> 0.0.5
```

Run `shards install`, then `require "couchbase"` in your application.

See [release notes](RELEASE_NOTES.md) for the complete feature set and limitations.

## Migrating From CryBase

Replace:
1. `crybase` dependency with `couchbase`
2. `require "crybase"` with `require "couchbase"`
3. `CryBase::CouchBase` with `CouchBase`

Shared helpers now live under `CouchBase::Connectivity` and
`CouchBase::Interfaces` <br/>
the version is `CouchBase::VERSION`.

## Index

1. [Glossary](docs/1.MANUAL_glossary.md)
2. [Installation](docs/2.MANUAL_installation.md)
3. [Quick start](docs/3.MANUAL_quick-start.md)
4. [Key Value service](docs/4.MANUAL_key-value-service.md)
5. [Query service](docs/5.MANUAL_query-service.md)

## Small Use Cases

```crystal
require "couchbase"

kv = CouchBase::KV::Client.from_string(
  "couchbase://Administrator:password@127.0.0.1/commerce",
)

kv.scope = "ecommerce_shop"
users = kv.collection("users")
users.set("some-uuid-here", %({"name":"Ada"}))
puts String.new(users.get("some-uuid-here"))

admins = kv.collection("admins")
admins.set("some-uuid-here", %({"name":"Grace"}))
```

```crystal
require "couchbase"

client = CouchBase::Query::Client.from_string(
  "couchbase://Administrator:password@127.0.0.1/commerce",
)

client.scope = "ecommerce_shop"

rows = client.query(
  "SELECT META(u).id AS doc_key, u.name FROM users AS u LIMIT 5",
)
```

## Examples

Each folder in [`examples/`](examples/) is a standalone Crystal application with
its own `shard.yml`, locked dependencies, README, and local models. Copy any
folder elsewhere and run `shards install` followed by `shards build`. Each
example's README includes its run command.
Examples use the published CouchBase shard and require no shared example files.

| Example | Demonstrates |
| --- | --- |
| [kemal_api](examples/kemal_api/) | Kemal REST `/users`, UUID keys, SQL++ pagination, and HTTP/database specs. |
| [kv_basics](examples/kv_basics/) | Raw values and typed JSON documents in collections. |
| [kv_expiration](examples/kv_expiration/) | Expiration, touch, and atomic get-and-touch. |
| [kv_cluster](examples/kv_cluster/) | KV connection pools and seed failover. |
| [cluster_probe](examples/cluster_probe/) | TCP reachability of service endpoints. |
| [kv_endpoint_from_cluster](examples/kv_endpoint_from_cluster/) | Connecting to a reachable KV endpoint. |
| [query_basics](examples/query_basics/) | Parameters, typed rows, and row iteration. |
| [query_cursor](examples/query_cursor/) | Query cluster seeds and streaming typed rows without buffering the result. |
| [query_prepared](examples/query_prepared/) | Explicit prepared statements and cached plans. |
| [query_mutations](examples/query_mutations/) | SQL++ INSERT, UPDATE, array changes, UPSERT, and DELETE. |
| [query_retry_policy](examples/query_retry_policy/) | Retry policy configuration; policy-based retries are not implemented. |

For a local Couchbase server and the HTTP API:

```sh
cd examples/kemal_api
docker compose up -d --wait couchbase
docker compose run --rm couchbase-init
shards install
crystal run setup.cr
crystal run src/main.cr
```

The API listens at `http://127.0.0.1:3000`. See its
[README](examples/kemal_api/README.md) for endpoint examples, configuration, and
spec commands. The same database supports the other examples:

```sh
cd ../query_basics
shards install
crystal run example.cr
```

CLI examples accept `COUCHBASE_URL` (default
`couchbase://Administrator:password@127.0.0.1/commerce`),
`COUCHBASE_SCOPE`, and `COUCHBASE_COLLECTION` (both `_default`). Query examples
also accept `COUCHBASE_QUERY_URL` for a separate Query endpoint. They create
their own data, clean up their UUID keys, and do not require a sample dataset.
