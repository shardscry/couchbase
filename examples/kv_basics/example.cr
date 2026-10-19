require "couchbase"
require "uuid"
require "./profile"

uri = ENV["COUCHBASE_URL"]? || "couchbase://Administrator:password@127.0.0.1/commerce"
client = CouchBase::KV::Client.from_string(uri)
client.scope = ENV["COUCHBASE_SCOPE"]? || "_default"
documents = client.collection(ENV["COUCHBASE_COLLECTION"]? || "_default")
key = UUID.random.to_s

begin
  cas = documents.set(key, "Hello, Couchbase")
  puts "CAS=#{cas}: #{String.new(documents.get(key))}"

  documents.set(key, Profile.new("Ada", 42))
  profile = documents.get_as(key, Profile)
  puts "#{profile.name} scored #{profile.score}"
ensure
  documents.delete(key) rescue nil
  client.close
end
