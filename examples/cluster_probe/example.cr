require "couchbase"

uri = ENV["COUCHBASE_URL"]? || "couchbase://127.0.0.1"
client = CouchBase::Client.new(uri, connect_timeout: 1.second)

begin
  client.connect.each { |endpoint| puts endpoint }
ensure
  client.close
end
