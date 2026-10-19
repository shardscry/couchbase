require "../spec_helper"

private alias Client = CouchBase::Client
private alias Service = CouchBase::Service

describe Client do
  it "enumerates every service endpoint per host" do
    client = Client.new("couchbase://h1,h2")
    client.endpoints.size.should eq(CouchBase::Services.list.size * 2)
    client.endpoints_for(Service::KV).map(&.host).should eq(["h1", "h2"])
    client.endpoints_for(Service::KV).first.port.should eq(11210)
  end

  it "uses TLS ports when scheme is couchbases" do
    client = Client.new("couchbases://h1")
    client.endpoints_for(Service::KV).first.port.should eq(11207)
  end
end
