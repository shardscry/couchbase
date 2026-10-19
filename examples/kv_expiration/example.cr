require "couchbase"
require "uuid"

uri = ENV["COUCHBASE_URL"]? || "couchbase://Administrator:password@127.0.0.1/commerce"
client = CouchBase::KV::Client.from_string(uri)
client.scope = ENV["COUCHBASE_SCOPE"]? || "_default"
documents = client.collection(ENV["COUCHBASE_COLLECTION"]? || "_default")
key = UUID.random.to_s

begin
  documents.set(key, "Short lived", expiry: 1_u32)
  sleep 2.seconds
  begin
    documents.get(key)
    raise "Expected the document to expire"
  rescue CouchBase::KV::NotFound
    puts "The document expired"
  end

  documents.set(key, "Extended with touch", expiry: 2_u32)
  documents.touch(key, 10_u32)
  sleep 3.seconds
  puts String.new(documents.get(key))

  documents.set(key, "Extended with get-and-touch", expiry: 2_u32)
  puts String.new(documents.get(key, expiry: 10_u32))
  sleep 3.seconds
  puts String.new(documents.get(key))
ensure
  documents.delete(key) rescue nil
  client.close
end
