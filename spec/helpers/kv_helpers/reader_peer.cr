module CouchBase::SpecHelpers::KVHelpers
  class ReaderPeer
    include CouchBase::Services::KV::ResponseReader

    @socket : IO

    def initialize(@socket : IO)
    end

    def call : CouchBase::Services::KV::Response
      read
    end
  end
end
