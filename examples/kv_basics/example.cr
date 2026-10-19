require "../shared/methods"

private alias Examples = CouchBaseExamples
private alias Profile = CouchBaseExamples::Structs::Profile

client = Examples.open_kv_client
documents = client.collection(Examples::COLLECTION)

cas = documents.set("couchbase:hello", "world")
puts "SET    couchbase:hello => CAS=#{cas}"

value = documents.get("couchbase:hello")
puts "GET    couchbase:hello => #{String.new(value)}"

documents.set("couchbase:profile", Profile.new("ada", 42))
profile = documents.get_as("couchbase:profile", Profile)
puts "GET    couchbase:profile => #{profile.name} scored #{profile.score}"

documents.set("couchbase:context", "current scope collection")
puts "GET    couchbase:context => #{String.new(documents.get("couchbase:context"))}"

# documents.delete("couchbase:hello")
# documents.delete("couchbase:profile")
# documents.delete("couchbase:context")
# puts "DELETE couchbase:hello"

client.close
