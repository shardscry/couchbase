ENV["KEMAL_ENV"] = "test"

require "spec"
require "spec-kemal"
require "set"
require "../src/app"
require "./helpers/service_container"

private alias User = KemalAPI::Entities::User
private alias Page = KemalAPI::Structs::Page
private alias UserPage = KemalAPI::Structs::PageResult(KemalAPI::Entities::User)

private alias Repository = KemalAPI::Contracts::UserRepository

class KemalAPI::MemoryUserRepository
  include KemalAPI::Contracts::UserRepository

  @users = {} of String => User

  def save(entity : User) : Nil
    @users[entity.id] = entity
  end

  def find(id : String) : User?
    @users[id]?
  end

  def delete(id : String) : Nil
    @users.delete(id)
  end

  def list(page : Page) : UserPage
    sorted = @users.values.sort_by!(&.id)
    users = page.offset >= sorted.size ? [] of User : sorted[page.offset.to_i, page.per_page]
    UserPage.new(users, page, @users.size.to_i64)
  end

  def close : Nil
  end
end

class KemalAPI::TrackingUserRepository
  include KemalAPI::Contracts::UserRepository

  getter inner : Repository
  @ids = Set(String).new

  def initialize(@inner : Repository)
  end

  def save(entity : User) : Nil
    @inner.save(entity)
    @ids << entity.id
  end

  def find(id : String) : User?
    @inner.find(id)
  end

  def delete(id : String) : Nil
    @inner.delete(id)
    @ids.delete(id)
  end

  def list(page : Page) : UserPage
    @inner.list(page)
  end

  def cleanup : Nil
    @ids.each { |id| @inner.delete(id) }
    @ids.clear
  end

  def close : Nil
    @inner.close
  end
end

module KemalAPI::SpecSupport
  INTEGRATION = ENV["COUCHBASE_INTEGRATION"]? == "1"
  CONTAINER   = TestContainer.new
  CONFIG      = CONTAINER.config
  REPOSITORY  = TrackingUserRepository.new(INTEGRATION ? Repositories::UserRepository.new(CONFIG, "kemal_api_spec_#{UUID.random}") : MemoryUserRepository.new)

  def self.json_headers : HTTP::Headers
    HTTP::Headers{"Content-Type" => "application/json"}
  end
end

Kemal.config.env = "test"
Kemal.config.logging = false
Kemal.config.serve_static = false
KemalAPI::SpecSupport::CONTAINER.user_repository_override = KemalAPI::SpecSupport::REPOSITORY
KemalAPI::SpecSupport::CONTAINER.app.mount
Kemal.config.setup

Spec.after_each { KemalAPI::SpecSupport::REPOSITORY.cleanup }
Spec.after_suite { KemalAPI::SpecSupport::REPOSITORY.close }

module KemalAPI::SpecSupport
  def self.create_user(name : String = "Ada") : User
    result = post "/users", KemalAPI::SpecSupport.json_headers,
      {name: name, email: "#{name.downcase}@example.com"}.to_json
    result.status_code.should eq(201)
    KemalAPI::Entities::User.from_json(result.body)
  end
end
