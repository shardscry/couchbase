require "../injectable"
require "../contracts/user_repository"
require "./base"
require "./user_lookup"

private alias User = KemalAPI::Entities::User

@[ADI::Register]
class KemalAPI::Handlers::UpdateUser
  include KemalAPI::Handlers::Base
  include KemalAPI::Handlers::UserLookup
  include KemalAPI::Injectable

  inject user_repository : KemalAPI::Contracts::UserRepository

  def call(env : HTTP::Server::Context) : String
    respond(env) do
      previous = find_user(env)
      input = read_input(env)
      user = User.new(input.name.strip, input.email, previous.id, previous.created_at)
      @user_repository.save(user)
      user.to_json
    end
  end
end
