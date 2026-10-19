require "./app"

container = ADI::ServiceContainer.new
user_repository = container.user_repository

begin
  container.app.mount
  Kemal.config.host_binding = ENV["HOST"]? || "127.0.0.1"
  Kemal.config.port = (ENV["PORT"]? || "3000").to_i
  Kemal.config.serve_static = false
  Kemal.run
ensure
  user_repository.close
end
