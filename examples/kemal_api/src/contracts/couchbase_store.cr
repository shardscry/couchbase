require "../structs/page"
require "../structs/page_result"

module KemalAPI::Contracts::CouchbaseStore(T)
  abstract def save(entity : T) : Nil
  abstract def find(id : String) : T?
  abstract def delete(id : String) : Nil
  abstract def list(page : KemalAPI::Structs::Page) : KemalAPI::Structs::PageResult(T)
  abstract def close : Nil
end
