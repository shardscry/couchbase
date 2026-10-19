require "kemal"

class KemalAPI::Handlers::Error
  def initialize(@status : Int32)
  end

  def call(env : HTTP::Server::Context) : String
    env.response.content_type = "application/json"
    {error: HTTP::Status.new(@status).description}.to_json
  end
end
