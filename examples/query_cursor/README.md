# Streaming SQL++ cursor

Seeds UUID-keyed users and streams typed rows through a single-use cursor without retaining the result rows.

The Query cluster uses the supplied static seeds (`discover_topology: false`),
which also works when Docker exposes different ports from the advertised nodes.
To demonstrate seed failover, set `COUCHBASE_QUERY_URL` to a multi-host URI while
keeping `COUCHBASE_URL` pointed at an available KV node.

This folder is a standalone Crystal application. Copy it anywhere; it requires no
files from this repository or any sibling example. Use Crystal 1.20.1 or newer.

## Run

With Couchbase Server 7+ running and the `commerce` bucket created:

```sh
shards install
crystal run example.cr
# Or: shards build --release && ./bin/example
```

Set `COUCHBASE_URL` to override the default connection:

```sh
export COUCHBASE_URL='couchbase://Administrator:password@127.0.0.1/commerce'
```

`COUCHBASE_SCOPE` and `COUCHBASE_COLLECTION` default to `_default`; create the
scope/collection first when choosing other names. For TLS, use `couchbases://`
and a trusted certificate (the URI supports `tls_verify` and `tls_hostname`).
The example removes only the UUID keys it creates and closes its connections.

Enable the Data and Query services. These queries use `USE KEYS`, so no index
or preloaded sample dataset is required. For separate Query and KV ports,
set `COUCHBASE_QUERY_URL` to the Query URI, including its bucket path; use port
8093 for plaintext Query or 18093 for TLS. A URI without an explicit port
selects the correct default for each service.
