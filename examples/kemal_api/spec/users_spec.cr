require "./spec_helper"

private alias Support = KemalAPI::SpecSupport
private alias User = KemalAPI::Entities::User

describe "Users REST API" do
  it "returns an empty first page with pagination metadata" do
    get "/users"
    response.status_code.should eq(200)
    response.content_type.should eq("application/json")
    JSON.parse(response.body).should eq(JSON.parse(%({"data":[],"page":1,"per_page":20,"total":0,"total_pages":0})))
  end

  it "creates a user with a UUID key and a Location header" do
    user = Support.create_user
    UUID.parse?(user.id, version: UUID::Version::V4).should_not be_nil
    response.headers["Location"].should eq("/users/#{user.id}")
    user.name.should eq("Ada")
    Time.parse_rfc3339(user.created_at)

    get "/users/#{user.id}"
    response.status_code.should eq(200)
    User.from_json(response.body).should eq(user)
  end

  it "accepts a JSON content type with a charset and trims names" do
    post "/users", HTTP::Headers{"Content-Type" => "application/json; charset=utf-8"},
      %({"name":" Ada ","email":"ada@example.com"})
    response.status_code.should eq(201)
    User.from_json(response.body).name.should eq("Ada")
  end

  it "ignores a supplied id and generates its own UUID" do
    id = UUID.random.to_s
    post "/users", Support.json_headers, {id: id, name: "Ada", email: "ada@example.com"}.to_json
    response.status_code.should eq(201)
    User.from_json(response.body).id.should_not eq(id)
  end

  ["{", "[]", "null", %({"name":"Ada"}), %({"name":3,"email":"a@example.com"})].each do |body|
    it "rejects malformed or incomplete JSON: #{body}" do
      post "/users", Support.json_headers, body
      response.status_code.should eq(400)
      JSON.parse(response.body)["error"].as_s.should_not be_empty
    end
  end

  it "rejects unsupported request content types" do
    post "/users", body: "name=Ada"
    response.status_code.should eq(415)
  end

  [{name: " ", email: "ada@example.com"}, {name: "Ada", email: "invalid"}].each do |input|
    it "rejects invalid user fields: #{input}" do
      post "/users", Support.json_headers, input.to_json
      response.status_code.should eq(422)
      get "/users"
      JSON.parse(response.body)["total"].as_i.should eq(0)
    end
  end

  it "replaces a user while preserving its id and creation timestamp" do
    previous = Support.create_user
    put "/users/#{previous.id}", Support.json_headers, {name: "Grace", email: "grace@example.com"}.to_json
    response.status_code.should eq(200)
    user = User.from_json(response.body)
    user.id.should eq(previous.id)
    user.created_at.should eq(previous.created_at)
    user.name.should eq("Grace")
    get "/users/#{user.id}"
    User.from_json(response.body).should eq(user)
  end

  it "leaves a user unchanged when an update is invalid" do
    user = Support.create_user
    put "/users/#{user.id}", Support.json_headers, %({"name":""})
    response.status_code.should eq(400)
    get "/users/#{user.id}"
    User.from_json(response.body).should eq(user)
  end

  it "deletes a user with an empty 204 response" do
    user = Support.create_user
    delete "/users/#{user.id}"
    response.status_code.should eq(204)
    response.body.should be_empty
    get "/users/#{user.id}"
    response.status_code.should eq(404)
  end

  it "returns JSON 404 responses for missing users and unknown routes" do
    id = UUID.random.to_s
    get "/users/#{id}"
    response.status_code.should eq(404)
    put "/users/#{id}", Support.json_headers, %({"name":"Ada","email":"ada@example.com"})
    response.status_code.should eq(404)
    delete "/users/#{id}"
    response.status_code.should eq(404)
    get "/missing"
    response.status_code.should eq(404)
    JSON.parse(response.body)["error"].as_s.should_not be_empty
  end

  it "rejects invalid UUIDs on each member route" do
    get "/users/not-a-uuid"
    response.status_code.should eq(400)
    put "/users/not-a-uuid", Support.json_headers, %({"name":"Ada","email":"ada@example.com"})
    response.status_code.should eq(400)
    delete "/users/not-a-uuid"
    response.status_code.should eq(400)
  end

  it "normalizes UUID casing when looking up users" do
    user = Support.create_user
    get "/users/#{user.id.upcase}"
    response.status_code.should eq(200)
    User.from_json(response.body).id.should eq(user.id)
  end

  it "lists disjoint, ordered pages and reports the total" do
    users = %w[Ada Grace Katherine].map { |name| Support.create_user(name) }
    get "/users?page=1&per_page=2"
    response.status_code.should eq(200)
    first = JSON.parse(response.body)
    first["total"].as_i.should eq(3)
    first["total_pages"].as_i.should eq(2)
    first["per_page"].as_i.should eq(2)

    get "/users?page=2&per_page=2"
    second = JSON.parse(response.body)
    second["page"].as_i.should eq(2)
    second["data"].as_a.size.should eq(1)
    ids = first["data"].as_a.map(&.["id"].as_s) + second["data"].as_a.map(&.["id"].as_s)
    ids.should eq(users.map(&.id).sort!)

    get "/users?page=3&per_page=2"
    last = JSON.parse(response.body)
    last["data"].as_a.should be_empty
    last["total"].as_i.should eq(3)
  end

  %w[page=0 page=-1 page=abc page=2147483648 per_page=0 per_page=101 per_page=1.5 per_page=bad].each do |query|
    it "rejects invalid pagination: #{query}" do
      get "/users?#{query}"
      response.status_code.should eq(400)
      JSON.parse(response.body)["error"].as_s.should_not be_empty
    end
  end

  it "handles large offsets without integer overflow" do
    get "/users?page=2147483647&per_page=100"
    response.status_code.should eq(200)
    JSON.parse(response.body)["data"].as_a.should be_empty
  end
end
