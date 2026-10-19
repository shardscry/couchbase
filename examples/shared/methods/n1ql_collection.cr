require "../structs"
require "./n1ql_identifier"

module CouchBaseExamples
  def self.n1ql_collection : String
    n1ql_identifier(QUERY_COLLECTION)
  end
end
