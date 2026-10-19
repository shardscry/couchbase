require "./handlers/create_user"
require "./handlers/list_users"
require "./handlers/get_user"
require "./handlers/update_user"
require "./handlers/delete_user"
require "./handlers/error"

@[ADI::Register]
class KemalAPI::Routing
  def initialize(
    @create_user : KemalAPI::Handlers::CreateUser,
    @list_users : KemalAPI::Handlers::ListUsers,
    @get_user : KemalAPI::Handlers::GetUser,
    @update_user : KemalAPI::Handlers::UpdateUser,
    @delete_user : KemalAPI::Handlers::DeleteUser,
  )
  end

  def mount : Nil
    router = Kemal::Router.new

    router.post("/users") { |env| @create_user.call(env) }
    router.get("/users") { |env| @list_users.call(env) }
    router.get("/users/:id") { |env| @get_user.call(env) }
    router.put("/users/:id") { |env| @update_user.call(env) }
    router.delete("/users/:id") { |env| @delete_user.call(env) }
    router.register_routes

    {400, 404, 405, 413, 500}.each do |status|
      handler = Handlers::Error.new(status)
      Kemal.config.add_error_handler(status) { |env, _error| handler.call(env) }
    end
  end
end
