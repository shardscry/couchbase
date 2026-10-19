require "./spec_helper"

private alias Support = KemalAPI::SpecSupport
private alias User = KemalAPI::Entities::User

describe "Application dependency injection" do
  it "injects the registered test repository into the application" do
    Support::CONTAINER.user_repository.should be(Support::REPOSITORY)
    user = Support.create_user
    Support::REPOSITORY.find(user.id).should eq(user)
  end

  it "reuses application and configuration services within one container" do
    Support::CONTAINER.app.should be(Support::CONTAINER.app)
    Support::CONTAINER.config.should be(Support::CONFIG)
  end

  it "keeps repository bindings isolated between containers" do
    first = KemalAPI::TestContainer.new
    second = KemalAPI::TestContainer.new
    first_repository = KemalAPI::MemoryUserRepository.new
    second_repository = KemalAPI::MemoryUserRepository.new
    first.user_repository_override = first_repository
    second.user_repository_override = second_repository

    user = User.new("Ada", "ada@example.com", UUID.random.to_s, Time.utc.to_rfc3339)
    first.user_repository.save(user)

    first.user_repository.find(user.id).should eq(user)
    second.user_repository.find(user.id).should be_nil
    first.app.should_not be(second.app)
  end
end
