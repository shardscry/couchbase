require "couchbase"
require "uuid"

uri = ENV["COUCHBASE_URL"]? || "couchbase://Administrator:password@127.0.0.2,127.0.0.1/commerce"
client = CouchBase::KV::Cluster.from_string(uri, size: 2, connect_timeout: 1.second)
client.scope = ENV["COUCHBASE_SCOPE"]? || "_default"
documents = client.collection(ENV["COUCHBASE_COLLECTION"]? || "_default")
key = UUID.random.to_s

begin
  documents.set(key, "Connected through an available seed")
  puts "Endpoint: #{client.active_endpoint}"
  puts String.new(documents.get(key))
ensure
  documents.delete(key) rescue nil
  client.close
end
