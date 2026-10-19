#!/usr/bin/env bash
set -euo pipefail

manager=http://couchbase:8091
username=Administrator
password=password
bucket=commerce

if ! curl -fsS -u "$username:$password" "$manager/pools/default" >/dev/null; then
  couchbase-cli cluster-init --cluster "$manager" \
    --cluster-username "$username" --cluster-password "$password" \
    --services data,index,query --cluster-ramsize 512 --cluster-index-ramsize 256
fi

status=$(curl -sS -u "$username:$password" -o /tmp/bucket.json -w '%{http_code}' \
  "$manager/pools/default/buckets/$bucket")
case "$status" in
  200) ;;
  404)
    couchbase-cli bucket-create --cluster "$manager" \
      --username "$username" --password "$password" --bucket "$bucket" \
      --bucket-type couchbase --bucket-ramsize 256 --bucket-replica 0
    ;;
  *) cat /tmp/bucket.json; exit 1 ;;
esac

for attempt in {1..60}; do
  status=$(curl -sS -u "$username:$password" -o /tmp/collection.json -w '%{http_code}' \
    --data-urlencode name=users "$manager/pools/default/buckets/$bucket/scopes/_default/collections")
  case "$status" in
    200|409) echo "Ready: commerce._default.users (Administrator / password)"; exit 0 ;;
    400)
      if grep -Fq 'Collection with name \"users\" in scope \"_default\" already exists' /tmp/collection.json; then
        echo "Ready: commerce._default.users (already initialized)"
        exit 0
      fi
      ;;
  esac
  sleep 2
done

cat /tmp/collection.json
exit 1
