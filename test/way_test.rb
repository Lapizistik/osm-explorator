# -*- coding: utf-8 -*-

gem "minitest"

require "minitest/spec"
require "minitest/autorun"

require "osmexplorator"

include OSMExplorator

# Way
describe Way do

  it "exists" do
    true.must_equal(true)
  end

end

# WayInstance
describe WayInstance do

  it "exists" do
    true.must_equal(true)
  end

end
