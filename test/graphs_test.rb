# -*- coding: utf-8 -*-

gem "minitest"

require "minitest/spec"
require "minitest/autorun"

require "osmexplorator"

include OSMExplorator

# Datastore Graph Analysis
describe Datastore do

  it "exists" do
    true.must_equal(true)
  end

end

# Region Graph Analysis
describe Region do

  it "exists" do
    true.must_equal(true)
  end

end

# General OSMObject Graph Analysis
describe OSMObject do

  it "exists" do
    true.must_equal(true)
  end

end
