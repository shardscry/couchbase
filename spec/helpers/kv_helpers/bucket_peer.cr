module CouchBase::SpecHelpers::KVHelpers
  class BucketPeer
    include CouchBase::Services::KV::RequestWriter
    include CouchBase::Services::KV::ResponseReader
    include CouchBase::Services::KV::Bucket

    @socket : IO

    def initialize(@socket : IO)
    end

    def call(name : String) : Nil
      use(name)
    end
  end
end
