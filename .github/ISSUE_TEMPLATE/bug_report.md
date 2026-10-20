---
name: Bug report
about: Report a reproducible defect in the CouchBase shard
title: "[BUG] <short summary>"
labels: bug
assignees: num8er
---

<!-- Remove credentials, document contents, and other private data from examples and logs. -->

## Summary

<!-- Describe the failing KV, Query, or cluster operation. -->

## Environment

- Shard version or commit (`CouchBase::VERSION`):
- Crystal version (`crystal --version`):
- Couchbase Server version or Capella deployment:
- OS and architecture:
- Affected service: KV / Query / cluster discovery
- Connection: TCP / TLS; direct node / proxy / load balancer
- Bucket, scope, collection, and relevant timeout/retry settings:

<!-- For TLS issues, describe certificate trust configuration without sharing private keys. -->

## Minimal reproduction

<!-- Include a self-contained Crystal snippet or repository link. For Query issues,
include SQL++, required indexes, and a small sample document when relevant. -->

```crystal

```

## Steps to reproduce

1.
2.
3.

## Expected behavior

<!-- What did you expect to happen? -->

## Actual behavior

<!-- Describe the result and include the full error or relevant logs. -->

```text

```

## Additional context

<!-- Optional: regression version, frequency, related issues, or a workaround. -->
