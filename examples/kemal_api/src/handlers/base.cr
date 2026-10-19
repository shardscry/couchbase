require "kemal"
require "couchbase"
require "../errors/request_error"
require "../structs/user_input"

private alias Context = HTTP::Server::Context
private alias RequestError = KemalAPI::Errors::RequestError
private alias UserInput = KemalAPI::Structs::UserInput

module KemalAPI::Handlers::Base
  protected def respond(env : Context, & : -> String) : String
    env.response.content_type = "application/json"
    yield
  rescue ex : RequestError
    env.response.status_code = ex.status
    {error: ex.message}.to_json
  rescue CouchBase::KV::NotFound
    env.response.status_code = 404
    {error: "user not found"}.to_json
  end

  protected def read_input(env : Context) : UserInput
    unless env.request.headers["Content-Type"]?.try(&.split(';', 2).first.strip.downcase) == "application/json"
      raise RequestError.new(415, "Content-Type must be application/json")
    end
    input = UserInput.from_json(env.params.raw_body)
    input.validate!
    input
  rescue JSON::ParseException
    raise RequestError.new(400, "body must be a JSON object containing name and email strings")
  end
end
