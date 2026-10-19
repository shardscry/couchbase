require "../injectable"
require "../contracts/user_repository"
require "./base"
require "./user_lookup"

@[ADI::Register]
class KemalAPI::Handlers::DeleteUser
  include KemalAPI::Handlers::Base
  include KemalAPI::Handlers::UserLookup
  include KemalAPI::Injectable

  inject user_repository : KemalAPI::Contracts::UserRepository

  def call(env : HTTP::Server::Context) : String
    respond(env) do
      user = find_user(env)
      @user_repository.delete(user.id)
      env.response.status_code = 204
      ""
    end
  end
end
