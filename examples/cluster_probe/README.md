# Service reachability

Lists reachable Couchbase service endpoints using TCP probes. This does not authenticate or validate service health.

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
