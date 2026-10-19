require "couchbase"
require "uuid"

uri = ENV["COUCHBASE_URL"]? || "couchbase://Administrator:password@127.0.0.1/commerce"
connection = CouchBase::ConnectionString.parse(uri)
cluster_client = CouchBase::Client.new(uri, connect_timeout: 1.second)
key = UUID.random.to_s

begin
  endpoint = cluster_client.connect.find(&.service.kv?) || raise "No reachable KV endpoint"
  puts "Using #{endpoint}"
  kv_client = CouchBase::KV::Client.from_string(endpoint.address,
    username: connection.username, password: connection.password, bucket: connection.bucket,
    tls_verify: connection.bool_param("tls_verify", true), tls_hostname: connection.param("tls_hostname"))
  kv_client.scope = ENV["COUCHBASE_SCOPE"]? || "_default"
  documents = kv_client.collection(ENV["COUCHBASE_COLLECTION"]? || "_default")
  begin
    documents.set(key, {name: "Ada"}.to_json)
    puts String.new(documents.get(key))
  ensure
    documents.delete(key) rescue nil
    kv_client.close
  end
ensure
  cluster_client.close
end
