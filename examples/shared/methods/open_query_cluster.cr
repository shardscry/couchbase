require "../structs"
require "./query_cluster_connection_string"

module CouchBaseExamples
  def self.open_query_cluster : CouchBase::Query::Cluster
    client = CouchBase::Query::Cluster.from_string(
      query_cluster_connection_string,
      tls_verify: TLS_VERIFY,
      tls_hostname: TLS_HOSTNAME,
    )
    client.scope = QUERY_SCOPE
    client
  end
end
