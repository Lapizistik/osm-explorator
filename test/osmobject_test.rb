# -*- coding: utf-8 -*-

gem "minitest"
gem 'mocha'

require "minitest/spec"
require "minitest/autorun"

require 'mocha/mini_test'

require "osmexplorator"

include OSMExplorator

# OSMObject
describe OSMObject do

  it "exists" do
    true.must_equal(true)
  end

end

# OSMObjectInstance
describe OSMObjectInstance do

  it "exists" do
    true.must_equal(true)
  end

end
