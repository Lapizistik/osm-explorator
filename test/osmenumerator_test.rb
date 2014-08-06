# -*- coding: utf-8 -*-

gem "minitest"

require "minitest/spec"
require "minitest/autorun"

require "osmexplorator"

include OSMExplorator

# OSMEnumerator
describe OSMEnumerator do

  it "exists" do
    true.must_equal(true)
  end

end

# GenericEnumerator
describe GenericEnumerator do

  it "exists" do
    true.must_equal(true)
  end

end

# FilteredEnumerator
describe FilteredEnumerator do

  it "exists" do
    true.must_equal(true)
  end

end

# NodeLocationHistoryEnumerator
describe NodeLocationHistoryEnumerator do

  it "exists" do
    true.must_equal(true)
  end

end
