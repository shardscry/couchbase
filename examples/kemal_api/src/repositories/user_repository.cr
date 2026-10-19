require "../contracts/couchbase_store"
require "../entities/user"
require "../config"

private alias User = KemalAPI::Entities::User
private alias Page = KemalAPI::Structs::Page
private alias UserPage = KemalAPI::Structs::PageResult(KemalAPI::Entities::User)

@[ADI::Register(name: "user_repository", public: true)]
class KemalAPI::Repositories::UserRepository
  include KemalAPI::Contracts::CouchbaseStore(KemalAPI::Entities::User)

  private alias KV = CouchBase::KV
  private alias Query = CouchBase::Query

  @kv_client : KV::Pool
  @client : Query::Client
  @users : KV::CollectionContext(KV::Pool)
  @keyspace : String

  def initialize(config : KemalAPI::Config, @document_type : String = "kemal_api_user")
    @keyspace = config.keyspace
    @kv_client = KV::Pool.from_string(config.uri(config.kv_port),
      username: config.username, password: config.password, bucket: config.bucket,
      management_port: config.management_port, size: 4)
    @users = begin
      @kv_client.scope = config.scope
      @kv_client.collection(config.collection)
    rescue ex
      @kv_client.close
      raise ex
    end
    @client = begin
      config.open_query_client
    rescue ex
      @kv_client.close
      raise ex
    end
  end

  def save(entity : User) : Nil
    document = {type: @document_type, name: entity.name, email: entity.email,
                id: entity.id, created_at: entity.created_at}
    @users.set(entity.id, document.to_json)
  end

  def find(id : String) : User?
    document = JSON.parse(String.new(@users.get(id)))
    return nil unless document["type"]?.try(&.as_s?) == @document_type

    User.from_json(document.to_json)
  rescue KV::NotFound
    nil
  end

  def delete(id : String) : Nil
    @users.delete(id)
  end

  def list(page : Page) : UserPage
    statement = <<-SQL
      SELECT META(u).id AS id, u.name, u.email, u.created_at
      FROM #{@keyspace} AS u
      WHERE u.type = $type
      ORDER BY META(u).id
      LIMIT $limit OFFSET $offset
      SQL
    rows = @client.query(
      statement,
      named_args: {type: @document_type, limit: page.per_page, offset: page.offset},
      readonly: true, scan_consistency: Query::ScanConsistency::RequestPlus,
    )
    count = @client.query(
      "SELECT RAW COUNT(1) FROM #{@keyspace} AS u WHERE u.type = $type",
      named_args: {type: @document_type}, readonly: true,
      scan_consistency: Query::ScanConsistency::RequestPlus,
    )
    UserPage.new(rows.rows_as(User), page, count.rows.first.as_i64)
  end

  def close : Nil
    @client.close
  ensure
    @kv_client.close
  end
end
