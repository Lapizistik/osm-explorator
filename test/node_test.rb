# -*- coding: utf-8 -*-

gem "minitest"

require "minitest/spec"
require "minitest/autorun"

require "osmexplorator"

include OSMExplorator

# Node
describe Node do

  it "exists" do
    true.must_equal(true)
  end

end

# NodeInstance
describe NodeInstance do

  it "exists" do
    true.must_equal(true)
  end

end
