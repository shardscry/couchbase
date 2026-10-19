require "../shared/methods"

private alias CouchbaseClient = CouchBase::Client
private alias Examples = CouchBaseExamples
private alias KVClient = CouchBase::KV::Client
private alias Profile = CouchBaseExamples::Structs::Profile
private alias Service = CouchBase::Service

cluster = CouchbaseClient.new(Examples.cluster_connection_string)
reachable = cluster.connect

kv_endpoints = reachable.select { |e| e.service == Service::KV }
abort "no reachable KV endpoints on #{Examples::HOST}" if kv_endpoints.empty?

endpoint = kv_endpoints.first
puts "Using KV endpoint: #{endpoint}"

kv = KVClient.from_string(Examples.kv_connection_string(endpoint))
kv.scope = Examples::SCOPE
kv.collection = Examples::COLLECTION

kv.set("couchbase:demo", Profile.new("ada", 42))
puts "stored couchbase:demo"
profile = kv.get_as("couchbase:demo", Profile)
puts "loaded: #{profile.name} scored #{profile.score}"
# kv.delete("couchbase:demo")

kv.close
cluster.close
