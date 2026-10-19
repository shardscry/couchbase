require "uuid"
require "../injectable"
require "../contracts/user_repository"
require "./base"

private alias User = KemalAPI::Entities::User

@[ADI::Register]
class KemalAPI::Handlers::CreateUser
  include KemalAPI::Handlers::Base
  include KemalAPI::Injectable

  inject user_repository : KemalAPI::Contracts::UserRepository

  def call(env : HTTP::Server::Context) : String
    respond(env) do
      input = read_input(env)
      user = User.new(input.name.strip, input.email, UUID.random.to_s, Time.utc.to_rfc3339)
      @user_repository.save(user)
      env.response.status_code = 201
      env.response.headers["Location"] = "/users/#{user.id}"
      user.to_json
    end
  end
end
