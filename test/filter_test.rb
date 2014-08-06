# -*- coding: utf-8 -*-

gem "minitest"

require "minitest/spec"
require "minitest/autorun"

require "osmexplorator"

include OSMExplorator

# Filter
describe Filter do

  it "exists" do
    true.must_equal(true)
  end

end

# TimeFilter
describe TimeFilter do

  it "exists" do
    true.must_equal(true)
  end

end
