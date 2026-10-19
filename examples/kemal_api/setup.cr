require "./src/config"

config = KemalAPI::Config.new
client = config.open_query_client

begin
  client.query("CREATE PRIMARY INDEX IF NOT EXISTS ON #{config.keyspace}")
  puts "Index ready on #{config.keyspace}"
ensure
  client.close
end
