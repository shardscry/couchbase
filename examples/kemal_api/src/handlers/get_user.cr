require "../injectable"
require "../contracts/user_repository"
require "./base"
require "./user_lookup"

@[ADI::Register]
class KemalAPI::Handlers::GetUser
  include KemalAPI::Handlers::Base
  include KemalAPI::Handlers::UserLookup
  include KemalAPI::Injectable

  inject user_repository : KemalAPI::Contracts::UserRepository

  def call(env : HTTP::Server::Context) : String
    respond(env) { find_user(env).to_json }
  end
end
