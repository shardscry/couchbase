require "kemal"
require "uuid"
require "../entities/user"
require "../errors/request_error"

private alias Context = HTTP::Server::Context
private alias RequestError = KemalAPI::Errors::RequestError
private alias User = KemalAPI::Entities::User

module KemalAPI::Handlers::UserLookup
  protected def find_user(env : Context) : User
    id = env.params.url["id"]
    uuid = UUID.parse?(id)
    raise RequestError.new(400, "id must be a UUID") unless uuid

    @user_repository.find(uuid.to_s) || raise RequestError.new(404, "user not found")
  end
end
