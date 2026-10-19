# Kemal users API

A standalone HTTP API using Kemal and the published CouchBase shard. This folder
contains all application code, dependencies, database setup, and specs; it can be
copied outside this repository. Requires Crystal 1.20.1+ and Couchbase Server 7+.

## Project structure

- `src/main.cr`: builds the application container, starts the API, and closes
  database connections on exit.
- `src/app.cr`: mounts the application's routing.
- `src/config.cr`: application configuration under `KemalAPI::Config`.
- `src/dependencies.cr`: binds the user repository to its persistence contract.
- `src/injectable.cr`: declares typed dependencies and generates injection
  constructors for handlers.
- `src/routing.cr`: maps HTTP methods and paths to handlers.
- `src/handlers/`: one handler per user action, plus shared request helpers and
  a JSON error handler.
- `src/handlers/base.cr`: an includable module for JSON responses and input parsing.
- `src/handlers/user_lookup.cr`: UUID validation and repository lookup, included
  only by handlers that fetch an existing user.
- `src/entities/user.cr`: a data-only `Entities::User` struct with JSON
  serialization; UUIDs and timestamps are supplied by the create handler.
- `src/repositories/user_repository.cr`: KV persistence and SQL++ pagination.
- `src/contracts/couchbase_store.cr`: the generic `CouchbaseStore(T)` contract
  implemented by repositories.
- `src/structs/`: request input, pagination parameters, and `PageResult(T)`.
- `src/errors/`: request error types.
- `spec/`: HTTP contract and real Couchbase persistence specs.

## Run locally

Start a disposable development database with Docker Compose:

```sh
docker compose up -d --wait couchbase
docker compose run --rm couchbase-init
shards install
crystal run setup.cr
crystal run src/main.cr
```

The initializer creates the `commerce` bucket and `_default.users` collection.
`setup.cr` creates a primary index for SQL++ listing. It can be run again safely.
The API listens on `http://127.0.0.1:3000`; Couchbase's console is at
`http://127.0.0.1:8091` (Administrator / password). Stop the API with Ctrl-C.

To build a binary: `shards build --release`, then `./bin/kemal_api`.
To remove this development database: `docker compose down -v`.

## Dependency injection

[Athena Dependency Injection](https://athenaframework.org/DependencyInjection/)
auto-wires services marked with `@[ADI::Register]`. `dependencies.cr` binds
`Contracts::UserRepository`, an alias for `CouchbaseStore(Entities::User)`, to
`Repositories::UserRepository`. Each concrete user handler includes HTTP helpers
and declares its own dependency:

```crystal
include KemalAPI::Handlers::Base
include KemalAPI::Injectable

inject user_repository : KemalAPI::Contracts::UserRepository
```

Handlers use `@user_repository.save(user)`, `@user_repository.find(id)`, and the
other contract methods. The `inject` macro generates the constructors that Athena
auto-wires. `Handlers::Base` is a module containing shared HTTP helpers, with no
repository dependency or injection declaration. The container constructs the
repository, handlers, routing, and application automatically.

`src/main.cr` creates one application container and resolves its `app` service.
All handlers share the same repository and four-connection KV pool. Request
handlers use their injected dependencies throughout the application's lifetime.

Specs use a `TestContainer` that overrides the repository binding before resolving
the application. The same HTTP contract runs with either an in-memory repository
or the real Couchbase repository. No production database connections are opened
by the in-memory specs.

## Endpoints

| Method | Path | Behavior |
| --- | --- | --- |
| POST | `/users` | Create a user, return 201 and a `Location` header. |
| GET | `/users?page=1&per_page=20` | List users through SQL++ with pagination metadata. |
| GET | `/users/:id` | Fetch a user by its UUID key. |
| PUT | `/users/:id` | Replace name/email, preserving id and creation time. |
| DELETE | `/users/:id` | Delete a user and return an empty 204 response. |

POST and PUT accept JSON with a nonblank `name` and an `email` address:

```sh
curl -i http://127.0.0.1:3000/users \
  -H 'Content-Type: application/json' \
  -d '{"name":"Ada","email":"ada@example.com"}'
curl 'http://127.0.0.1:3000/users?page=1&per_page=2'
# Replace UUID below with the id returned by POST:
curl http://127.0.0.1:3000/users/UUID
curl -X PUT http://127.0.0.1:3000/users/UUID \
  -H 'Content-Type: application/json' \
  -d '{"name":"Grace","email":"grace@example.com"}'
curl -i -X DELETE http://127.0.0.1:3000/users/UUID
```

The server generates UUID v4 document keys. User JSON contains `id`, `name`,
`email`, and `created_at`. Listing returns:

```json
{"data":[],"page":1,"per_page":20,"total":0,"total_pages":0}
```

`page` starts at 1; `per_page` defaults to 20 and accepts 1–100. Out-of-range
pages return an empty `data` array. SQL++ uses named LIMIT/OFFSET parameters,
orders by document UUID, and uses `RequestPlus` consistency to include completed
KV writes. A separate count query supplies totals. Concurrent writes can shift
offsets or change totals between those two queries.

Errors are JSON: malformed JSON/UUID/pagination returns 400, missing users 404,
unsupported content types 415, and invalid field values 422. Unexpected server
errors return a generic 500 response.

## Configuration

| Environment variable | Default |
| --- | --- |
| `HOST`, `PORT` | `127.0.0.1`, `3000` |
| `COUCHBASE_HOST` | `127.0.0.1` |
| `COUCHBASE_USER`, `COUCHBASE_PASS` | `Administrator`, `password` |
| `COUCHBASE_BUCKET` | `commerce` |
| `COUCHBASE_SCOPE`, `COUCHBASE_COLLECTION` | `_default`, `users` |
| `COUCHBASE_KV_PORT`, `COUCHBASE_QUERY_PORT` | `11210`, `8093` |
| `COUCHBASE_MANAGEMENT_PORT` | `8091` |

The included Compose initializer uses the development defaults. For an existing
server, create your configured bucket/scope/collection first, then run `setup.cr`.
A four-connection KV pool serves concurrent handlers; the Query client reuses
its HTTP connection. Updates perform a read followed by an upsert, so concurrent
updates use the last write. This teaching app has no authentication or CAS checks.

## Specs

```sh
crystal spec --error-trace                         # in-memory HTTP contract
COUCHBASE_INTEGRATION=1 crystal spec --error-trace # same contract against Couchbase
```

Run database setup first for integration tests. Specs cover UUID keys, CRUD,
validation, missing users, pagination boundaries, ordering, and totals. The real
database run also checks physical UUID keys, SQL++ visibility after KV changes,
and exclusion of unrelated documents. Each run uses a unique document type and
cleans up its own UUID keys; existing application users are left in place.
