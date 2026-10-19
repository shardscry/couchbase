module CouchBase::Interfaces
  # Common contract for Couchbase clients.
  # Subtypes carry their own auth, endpoint shape, and `connect` semantics
  # on top of this base.
  #
  # ```
  # client = CouchBase::Client.new("couchbase://localhost")
  # client.is_a?(CouchBase::Interfaces::Client) # => true
  # client.connection_string.hosts              # => ["localhost"]
  # client.connected?                           # => false
  # client.close
  # ```
  abstract class Client
    # The parsed connection string the client was constructed from.
    abstract def connection_string : ConnectionString

    # Releases any resources held by the client. Must be idempotent.
    abstract def close : Nil

    # Whether the client has completed a successful `connect`.
    abstract def connected? : Bool
  end
end
