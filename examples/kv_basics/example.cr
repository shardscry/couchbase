require "../shared/methods"

private alias Examples = CouchBaseExamples
private alias Profile = CouchBaseExamples::Structs::Profile

kv = Examples.open_kv_client

cas = kv.set("couchbase:hello", "world")
puts "SET    couchbase:hello => CAS=#{cas}"

value = kv.get("couchbase:hello")
puts "GET    couchbase:hello => #{String.new(value)}"

kv.set("couchbase:profile", Profile.new("ada", 42))
profile = kv.get_as("couchbase:profile", Profile)
puts "GET    couchbase:profile => #{profile.name} scored #{profile.score}"

context = kv.collection(Examples::COLLECTION)
context.set("couchbase:context", "current scope collection")
puts "GET    couchbase:context => #{String.new(context.get("couchbase:context"))}"

# kv.delete("couchbase:hello")
# kv.delete("couchbase:profile")
# kv.delete("couchbase:context")
# puts "DELETE couchbase:hello"

kv.close
