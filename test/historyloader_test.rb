gem "minitest"
require 'minitest/autorun'

require 'osmexplorator/historyloader'

require_relative './pglogin.rb'


include OSMExplorator


class TestHistoryLoader < MiniTest::Unit::TestCase

  def setup
    @hl = HistoryLoader.new(PgLogin::ACCESS)
  end

  def test_max_node_version
    nodeid = 2746087760
    
    maxversion = @hl.max_node_version(nodeid)
    
    assert (maxversion)
  end

end
