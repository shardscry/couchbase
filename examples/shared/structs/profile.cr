require "json"
require "../constants"

struct CouchBaseExamples::Structs::Profile
  include JSON::Serializable

  property name : String
  property score : Int32

  def initialize(@name : String, @score : Int32)
  end
end
