require "../shared/methods"

private alias Examples = CouchBaseExamples
private alias KVCluster = CouchBase::KV::Cluster

client = KVCluster.from_string(Examples.kv_cluster_connection_string, size: 2)
client.scope = Examples::SCOPE
client.collection = Examples::COLLECTION
documents = client.collection(Examples::COLLECTION)

key = "couchbase:cluster"
documents.set(key, "seed-failover")
puts "SET #{key}"
puts "GET #{key} => #{String.new(documents.get(key))}"

documents.set("#{key}:context", "current scope collection")
puts "GET #{key}:context => #{String.new(documents.get("#{key}:context"))}"

documents.delete(key)
documents.delete("#{key}:context")
puts "DELETE #{key}"

client.close
