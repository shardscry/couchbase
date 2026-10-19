require "./spec_helper"

private alias Support = KemalAPI::SpecSupport

if Support::INTEGRATION
  describe "Couchbase persistence" do
    it "stores the document under the UUID returned by POST /users" do
      user = Support.create_user
      config = Support::CONFIG
      client = CouchBase::KV::Client.from_string(config.uri(config.kv_port),
        username: config.username, password: config.password, bucket: config.bucket,
        management_port: config.management_port)
      begin
        client.scope = config.scope
        users = client.collection(config.collection)
        stored = users.get_as(user.id, KemalAPI::Entities::User)
        stored.should eq(user)
      ensure
        client.close
      end
    end

    it "sees new KV writes and deletions immediately through SQL++ pagination" do
      user = Support.create_user
      get "/users?per_page=1"
      response.status_code.should eq(200)
      page = JSON.parse(response.body)
      page["data"][0]["id"].as_s.should eq(user.id)
      page["total"].as_i.should eq(1)
      delete "/users/#{user.id}"
      response.status_code.should eq(204)
      get "/users"
      JSON.parse(response.body)["total"].as_i.should eq(0)
    end

    it "excludes other document types from the listing and member routes" do
      config = Support::CONFIG
      client = CouchBase::KV::Client.from_string(config.uri(config.kv_port),
        username: config.username, password: config.password, bucket: config.bucket,
        management_port: config.management_port)
      id = UUID.random.to_s
      begin
        client.scope = config.scope
        users = client.collection(config.collection)
        users.set(id, {type: "unrelated", name: "Other"}.to_json)
        get "/users/#{id}"
        response.status_code.should eq(404)
        get "/users"
        JSON.parse(response.body)["total"].as_i.should eq(0)
        delete "/users/#{id}"
        response.status_code.should eq(404)
        String.new(users.get(id)).should contain("unrelated")
      ensure
        users.try(&.delete(id))
        client.close
      end
    end
  end
end
