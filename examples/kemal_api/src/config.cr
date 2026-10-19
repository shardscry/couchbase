require "couchbase"
require "athena-dependency_injection"

@[ADI::Register(name: "config", public: true)]
class KemalAPI::Config
  getter host : String
  getter username : String
  getter password : String
  getter bucket : String
  getter scope : String
  getter collection : String
  getter kv_port : Int32
  getter query_port : Int32
  getter management_port : Int32

  def initialize
    @host = ENV["COUCHBASE_HOST"]? || "127.0.0.1"
    @username = ENV["COUCHBASE_USER"]? || "Administrator"
    @password = ENV["COUCHBASE_PASS"]? || "password"
    @bucket = ENV["COUCHBASE_BUCKET"]? || "commerce"
    @scope = ENV["COUCHBASE_SCOPE"]? || "_default"
    @collection = ENV["COUCHBASE_COLLECTION"]? || "users"
    @kv_port = (ENV["COUCHBASE_KV_PORT"]? || "11210").to_i
    @query_port = (ENV["COUCHBASE_QUERY_PORT"]? || "8093").to_i
    @management_port = (ENV["COUCHBASE_MANAGEMENT_PORT"]? || "8091").to_i
  end

  def uri(port : Int32) : String
    URI.new(scheme: "couchbase", host: @host, port: port).to_s
  end

  def keyspace : String
    {@bucket, @scope, @collection}.map { |name| "`#{name.gsub("`", "``")}`" }.join('.')
  end

  def open_query_client : CouchBase::Query::Client
    client = CouchBase::Query::Client.from_string(uri(@query_port), username: @username,
      password: @password, bucket: @bucket)
    client.scope = @scope
    client
  end
end
