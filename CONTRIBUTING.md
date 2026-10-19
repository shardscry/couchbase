# Contributing to CouchBase

Thanks for your interest in CouchBase. This document explains how to set up
the project, the conventions we follow, and how to send a change for review.

By participating in this project you agree to abide by the
[Code of Conduct](CODE_OF_CONDUCT.md).

---

## Getting set up

You'll need [Crystal](https://crystal-lang.org/install/) `>= 1.20.1`.

```sh
git clone https://github.com/shardscry/couchbase.git
cd couchbase
shards install
shards build ameba
crystal spec
```

Unit specs use local protocol test servers. Real-server specs are enabled with
`COUCHBASE_INTEGRATION=1` and require an initialized Couchbase server.

Start the example environment, then run the integration suite:

```sh
docker compose -f examples/docker-compose.yml up -d
COUCHBASE_INTEGRATION=1 COUCHBASE_HOST=127.0.0.1 \
COUCHBASE_USER=Administrator COUCHBASE_PASS=password \
COUCHBASE_BUCKET=commerce crystal spec spec/integration
```

TLS specs also require `COUCHBASE_TLS=true` and the matching TLS service ports.

---

## Workflow

1. **Open an issue first** for non-trivial changes so we can align on scope
   before you write code. Use the issue templates in
   [`.github/ISSUE_TEMPLATE`](.github/ISSUE_TEMPLATE).
2. **Fork & branch.** Branch names like `feat/query-service`,
   `fix/tls-port-mapping`, `docs/readme` are appreciated.
3. **Write tests.** Every new public API or bug fix should come with a spec.
4. **Keep PRs focused.** Smaller PRs ship faster than mega-PRs.

---

## Project conventions

These are non-obvious rules the project follows. They override defaults
you might be used to from other Crystal codebases.

### File & namespace layout

- One **flat** namespace declaration per file
  (`module CouchBase`) — never deeply nested module blocks.
- The folder tree mirrors the namespace:
  `CouchBase::Client` lives in
  `src/couchbase/client.cr`.
- Specs mirror the source tree under `spec/`.

### Aliases

When a file references the same fully-qualified type more than a couple
of times, declare an alias near the top:

```crystal
private alias Client = CouchBase::Client
private alias Service = CouchBase::Service
```

Use `private alias` in spec/source files so the binding is scoped to the
file and won't collide with another file that aliases the same short
name.

### Style

Run the formatter before committing:

```sh
crystal tool format
bin/ameba
```

Default to writing **no comments**. Add one only when the *why* is
non-obvious (a hidden constraint, a workaround, a subtle invariant).
Don't comment what well-named identifiers already say.

---

## Testing

```sh
crystal spec                                       # whole suite
crystal spec spec/couchbase/client_spec.cr # single file
crystal spec -e "uses TLS ports"                   # by example name
```

CI runs `crystal tool format --check` and `crystal spec` on every PR.

---

## Commit messages

We follow a relaxed [Conventional Commits](https://www.conventionalcommits.org/)
style:

```
feat(client): add Query service handshake
fix(connection_string): treat trailing slash as empty path
docs(readme): document TLS port table
```

Common types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`.

---

## Releasing

Maintainers only:

1. Bump `version:` in `shard.yml` and `VERSION` in
   `src/couchbase/version.cr`.
2. Add a section to `CHANGELOG.md` for the new version.
3. Tag the release: `git tag v0.0.x && git push --tags`.
4. Create a GitHub release pointing at the tag.

---

## Questions?

- Bug or concrete feature → [open an issue](https://github.com/shardscry/couchbase/issues/new/choose).
- Open-ended question → start a [Discussion](https://github.com/shardscry/couchbase/discussions).
