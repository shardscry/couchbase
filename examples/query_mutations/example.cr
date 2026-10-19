require "couchbase"
require "uuid"

uri = ENV["COUCHBASE_QUERY_URL"]? || ENV["COUCHBASE_URL"]? || "couchbase://Administrator:password@127.0.0.1/commerce"
client = CouchBase::Query::Client.from_string(uri)
client.scope = ENV["COUCHBASE_SCOPE"]? || "_default"
collection = ENV["COUCHBASE_COLLECTION"]? || "_default"
keyspace = "`#{collection.gsub("`", "``")}`"
id = UUID.random.to_s
document = {name: "Ada", active: true, events: [{name: "welcome", done: false}]}

begin
  inserted = client.query("INSERT INTO #{keyspace} (KEY, VALUE) VALUES ($id, $doc) RETURNING META().id AS id, name",
    named_args: {id: id, doc: document})
  puts "INSERT: #{inserted.rows.to_json}"

  updated = client.query("UPDATE #{keyspace} AS u USE KEYS $id SET u.active = $active RETURNING u.name, u.active",
    named_args: {id: id, active: false})
  puts "UPDATE: #{updated.rows.to_json}"

  events = client.query(<<-SQL, named_args: {id: id, event: "welcome"})
    UPDATE #{keyspace} AS u USE KEYS $id
    SET event.done = true FOR event IN u.events WHEN event.name = $event END
    RETURNING u.events
    SQL
  puts "Array mutation: #{events.rows.to_json}"

  upserted = client.query("UPSERT INTO #{keyspace} (KEY, VALUE) VALUES ($id, $doc) RETURNING name",
    named_args: {id: id, doc: document.merge({name: "Grace"})})
  puts "UPSERT: #{upserted.rows.to_json}"

  deleted = client.query("DELETE FROM #{keyspace} AS u USE KEYS $id RETURNING META(u).id AS id", named_args: {id: id})
  puts "DELETE: #{deleted.rows.to_json}"
ensure
  begin
    client.query("DELETE FROM #{keyspace} USE KEYS $id", named_args: {id: id})
  ensure
    client.close
  end
end
