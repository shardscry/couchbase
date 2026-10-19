require "../../src/app"

class KemalAPI::TestContainer < ADI::ServiceContainer
  property user_repository_override : KemalAPI::Contracts::UserRepository?

  def user_repository : KemalAPI::Contracts::UserRepository
    @user_repository_override || super
  end
end
