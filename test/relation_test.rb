# -*- coding: utf-8 -*-

gem "minitest"

require "minitest/spec"
require "minitest/autorun"

require "osmexplorator"

include OSMExplorator

# Relation
describe Relation do

  it "exists" do
    true.must_equal(true)
  end

end

# RelationInstance
describe RelationInstance do

  it "exists" do
    true.must_equal(true)
  end

end
