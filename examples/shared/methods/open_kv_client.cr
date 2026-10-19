require "../structs"
require "./kv_connection_string"

module CouchBaseExamples
  def self.open_kv_client : CouchBase::KV::Client
    client = CouchBase::KV::Client.from_string(
      kv_connection_string,
      tls_verify: TLS_VERIFY,
      tls_hostname: TLS_HOSTNAME,
    )
    client.scope = SCOPE
    client.collection = COLLECTION
    client
  end
end
