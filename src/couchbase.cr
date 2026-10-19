require "socket"
require "uri"

# Standalone Crystal client for Couchbase KV and Query services.
#
# ```
# require "couchbase"
#
# client = CouchBase::KV::Client.from_string(
#   "couchbase://Administrator:password@localhost/default",
# )
# client.set("hello", %({"hello":"world"}))
# client.close
# ```
#
# `Client` probes service endpoints. Protocol clients live under `KV` and `Query`.
module CouchBase
end

require "./couchbase/version"
require "./couchbase/connectivity"
require "./couchbase/interfaces"
require "./couchbase/service"
require "./couchbase/endpoint"
require "./couchbase/connection_string"
require "./couchbase/policies"
require "./couchbase/services"
require "./couchbase/client"

module CouchBase
  alias RetryPolicy = Policies::RetryPolicy
  alias KV = Services::KV
  alias Query = Services::Query
end
