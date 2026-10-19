require "../shared/methods"

private alias CouchbaseClient = CouchBase::Client
private alias Examples = CouchBaseExamples
private alias KVClient = CouchBase::KV::Client
private alias Profile = CouchBaseExamples::Structs::Profile
private alias Service = CouchBase::Service

probe_client = CouchbaseClient.new(Examples.cluster_connection_string)
reachable = probe_client.connect

kv_endpoints = reachable.select { |e| e.service == Service::KV }
abort "no reachable KV endpoints on #{Examples::HOST}" if kv_endpoints.empty?

endpoint = kv_endpoints.first
puts "Using KV endpoint: #{endpoint}"

client = KVClient.from_string(Examples.kv_connection_string(endpoint))
client.scope = Examples::SCOPE
client.collection = Examples::COLLECTION
documents = client.collection(Examples::COLLECTION)

documents.set("couchbase:demo", Profile.new("ada", 42))
puts "stored couchbase:demo"
profile = documents.get_as("couchbase:demo", Profile)
puts "loaded: #{profile.name} scored #{profile.score}"
# documents.delete("couchbase:demo")

client.close
probe_client.close
