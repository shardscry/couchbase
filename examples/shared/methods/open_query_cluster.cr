require "../structs"
require "./query_cluster_connection_string"

module CouchBaseExamples
  def self.open_query_cluster : CouchBase::Query::Cluster
    cluster = CouchBase::Query::Cluster.from_string(
      query_cluster_connection_string,
      tls_verify: TLS_VERIFY,
      tls_hostname: TLS_HOSTNAME,
    )
    cluster.scope = QUERY_SCOPE
    cluster
  end
end
