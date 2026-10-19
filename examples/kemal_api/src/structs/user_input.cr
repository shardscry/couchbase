require "json"
require "../errors/request_error"

private alias RequestError = KemalAPI::Errors::RequestError

struct KemalAPI::Structs::UserInput
  include JSON::Serializable

  getter name : String
  getter email : String

  def validate! : Nil
    raise RequestError.new(422, "name must not be blank") if name.strip.empty?
    unless email.matches?(/\A[^\s@]+@[^\s@]+\.[^\s@]+\z/)
      raise RequestError.new(422, "email must be a valid address")
    end
  end
end
