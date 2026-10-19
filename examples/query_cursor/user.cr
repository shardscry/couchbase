require "json"

struct User
  include JSON::Serializable

  getter id : String
  getter name : String
  getter email : String
  getter? active : Bool

  def initialize(@id : String, @name : String, @email : String, @active : Bool)
  end
end
