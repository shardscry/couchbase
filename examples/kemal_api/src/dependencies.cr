require "./repositories/user_repository"
require "./contracts/user_repository"

ADI.bind user_repository : KemalAPI::Contracts::UserRepository, "@user_repository"
