# -*- coding: utf-8 -*-

gem "minitest"

require "minitest/spec"
require "minitest/autorun"

require "osmexplorator"

include OSMExplorator

describe Overpass do

  it "exists" do
    true.must_equal(true)
  end

end
