require "uuid"

module CouchBase::SpecHelpers::QueryFixtures
  struct User
    include JSON::Serializable

    getter id : String
    getter name : String
    getter email : String
    getter? active : Bool
    getter type : String = "User"

    def initialize(@id : String, @name : String, @email : String, @active : Bool)
    end
  end

  def self.seed_query_users(client : CouchBase::KV::Client, count : Int32 = 8) : Array(User)
    users = [] of User
    begin
      count.times do |index|
        user = User.new("User:#{UUID.random}", "User #{index}", "user#{index}@example.com", index.even?)
        client.set(user.id, user)
        users << user
      end
    rescue ex
      delete_query_users(client, users)
      raise ex
    end
    users
  end

  def self.delete_query_users(client : CouchBase::KV::Client, users : Array(User)) : Nil
    users.each { |user| client.delete(user.id) rescue nil }
  end

  def self.query_user_keys(users : Array(User)) : Array(String)
    users.map(&.id)
  end

  def self.n1ql_collection : String
    "`_default`"
  end
end
