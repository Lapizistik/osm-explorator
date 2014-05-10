require 'test/unit'
require 'osmexplorator'

class OSMExploratorTest < Test::Unit::TestCase

	def test_success
		assert_equal true, true
	end
  
  def test_wayHistory
    json_way = {
      :id => 123,
      :version => 7,
      :nodes => [1,2,3,4,5],
      :timestamp => "2013-01-07 00:00:00 +0100",
      :changeset => 1,
      :uid => 1,
      :user => "test_WayHistory",
      :tags => {:tagversion => "final"}
    }
    
    # TODO: 
    # 1. Create new way using a datastore mock
    # 2. "Load" history (manipulated)
    # 3. Call way.history_by_nodes
    # 4. Compare with predetermined result
    
    assert_equal true, true
  end
end
