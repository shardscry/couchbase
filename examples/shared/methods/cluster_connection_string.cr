require "../structs"

module CouchBaseExamples
  def self.cluster_connection_string : String
    "#{SCHEME}://#{HOST}"
  end
end
