require "json"

struct Profile
  include JSON::Serializable

  getter name : String
  getter score : Int32

  def initialize(@name : String, @score : Int32)
  end
end
