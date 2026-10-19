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
