require "../injectable"
require "../contracts/user_repository"
require "./base"

private alias Page = KemalAPI::Structs::Page

@[ADI::Register]
class KemalAPI::Handlers::ListUsers
  include KemalAPI::Handlers::Base
  include KemalAPI::Injectable

  inject user_repository : KemalAPI::Contracts::UserRepository

  def call(env : HTTP::Server::Context) : String
    respond(env) do
      page = Page.new(env.params.query["page"]?, env.params.query["per_page"]?)
      @user_repository.list(page).to_json
    end
  end
end
