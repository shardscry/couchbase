# KV seed failover

Tries multiple seeds and prints the endpoint selected for a small KV pool. This is seed failover; vbucket-map routing is not implemented.

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

Without `COUCHBASE_URL`, the first seed is `127.0.0.2` and the fallback is
`127.0.0.1`. To try your own seeds:

```sh
COUCHBASE_URL='couchbase://Administrator:password@unavailable,node1/commerce' crystal run example.cr
```
