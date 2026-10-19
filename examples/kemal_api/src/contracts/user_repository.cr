require "./couchbase_store"
require "../entities/user"

alias KemalAPI::Contracts::UserRepository = KemalAPI::Contracts::CouchbaseStore(KemalAPI::Entities::User)
