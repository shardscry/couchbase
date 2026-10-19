require "../structs"

module CouchBaseExamples
  private def self.n1ql_identifier(value : String) : String
    "`#{value.gsub("`", "``")}`"
  end
end
