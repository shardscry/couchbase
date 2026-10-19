module CouchBase::SpecHelpers::KVHelpers
  class WriterPeer
    include CouchBase::Services::KV::RequestWriter

    @socket : IO

    def initialize(@socket : IO)
    end

    def call(request : CouchBase::Services::KV::Request) : Nil
      write(request)
    end
  end
end
