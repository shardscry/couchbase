require "../shared/methods"

private alias Examples = CouchBaseExamples

client = Examples.open_kv_client
documents = client.collection(Examples::COLLECTION)

key = "couchbase:expiration"

documents.set(key, "short lived", expiry: 2_u32)
puts "SET    #{key} with expiry=2s"

sleep 1.second
documents.touch(key, 10_u32)
puts "TOUCH  #{key} with expiry=10s"

sleep 2.seconds
puts "GET    #{key} => #{String.new(documents.get(key))}"

documents.set(key, "get and touch", expiry: 2_u32)
puts "SET    #{key} with expiry=2s"

sleep 1.second
puts "GAT    #{key} => #{String.new(documents.get(key, expiry: 10_u32))}"

sleep 2.seconds
puts "GET    #{key} => #{String.new(documents.get(key))}"

documents.delete(key)
puts "DELETE #{key}"

client.close
