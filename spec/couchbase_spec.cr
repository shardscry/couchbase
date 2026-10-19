require "./spec_helper"

describe CouchBase do
  it "exposes a non-empty VERSION" do
    CouchBase::VERSION.empty?.should be_false
  end

  it "VERSION matches semver-ish shape" do
    (CouchBase::VERSION =~ /\A\d+\.\d+\.\d+\z/).should_not be_nil
  end
end
