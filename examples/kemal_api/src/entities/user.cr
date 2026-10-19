require "json"

struct KemalAPI::Entities::User
  include JSON::Serializable

  getter id : String
  getter name : String
  getter email : String
  getter created_at : String

  def initialize(@name : String, @email : String, @id : String, @created_at : String)
  end
end
