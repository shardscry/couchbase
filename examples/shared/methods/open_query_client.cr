require "../structs"
require "./query_connection_string"

module CouchBaseExamples
  def self.open_query_client : CouchBase::Query::Client
    client = CouchBase::Query::Client.from_string(
      query_connection_string,
      tls_verify: TLS_VERIFY,
      tls_hostname: TLS_HOSTNAME,
    )
    client.scope = QUERY_SCOPE
    client
  end
end
