require "../structs"
require "./n1ql_identifier"

module CouchBaseExamples
  def self.n1ql_bucket : String
    n1ql_identifier(BUCKET)
  end
end
