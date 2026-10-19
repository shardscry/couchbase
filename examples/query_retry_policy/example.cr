require "couchbase"
require "uuid"
require "./user"

uri = ENV["COUCHBASE_URL"]? || "couchbase://Administrator:password@127.0.0.1/commerce"
query_uri = ENV["COUCHBASE_QUERY_URL"]? || uri
kv_client = CouchBase::KV::Client.from_string(uri)
client = CouchBase::Query::Client.from_string(query_uri)
scope = ENV["COUCHBASE_SCOPE"]? || "_default"
collection = ENV["COUCHBASE_COLLECTION"]? || "_default"
kv_client.scope = scope
client.scope = scope
users = kv_client.collection(collection)
keyspace = "`#{collection.gsub("`", "``")}`"
keys = [] of String
statement = <<-SQL
  SELECT META(u).id AS id, u.name, u.email, u.active
  FROM #{keyspace} AS u USE KEYS $ids
  WHERE u.active = $active
  ORDER BY u.name
  SQL

begin
  %w[Ada Grace Katherine].each_with_index do |name, index|
    id = UUID.random.to_s
    keys << id
    users.set(id, User.new(id, name, "#{name.downcase}@example.com", index.even?))
  end

  policy = CouchBase::RetryPolicy.new(max_attempts: 3, delay: 50.milliseconds,
    jitter: 0.2, max_elapsed: 500.milliseconds, retry_query_errors: true, retry_transport_errors: true)
  result = client.query(statement, named_args: {ids: keys, active: true},
    readonly: true, retry_policy: policy)
  result.each_row_as(User) { |user| puts user.name }
  puts "Policy values are accepted; automatic policy-based retries are not implemented."
ensure
  keys.each { |id| users.delete(id) rescue nil }
  kv_client.close
  client.close
end
