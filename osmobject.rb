# -*- coding: utf-8 -*-

module OSMExplorator

  # An OSM Object, such as a Node, Way or Relation
  class OSMObject
    attr_reader :id, :current, :datastore
    
    def initialize(datastore, current)
      raise "datastore #{datastore} must be a "+
            "Datastore!" unless datastore.kind_of?(Datastore)

      @datastore = datastore
      
      @id = @current.id

      @regions = []
      @history = [@current]
    end
    
    def add_to_region(region)
      raise "region #{region} must be a "+
            "Region!" unless region.kind_of?(Region)

      @regions << region
    end
    
    # Returns a complete history of this node
    def history(hl=nil)
      load_history(hl) unless @loaded
      
      @loaded = true
      
      return @history
    end
    
    def all_users
      return @history.map { |oi| oi.user }
    end
       
    def inspect
      return "#<#{self.class}:#{object_id*2} "+
             "id => #{@id}, "+
             "datastore => #{@datastore.object_id*2}, "+
             "history => #{@history.map { |oi| oi.version }}, "+
             "regions => #{@regions.map { |r| r.id }}, "+
             "current => #{@current.object_id*2}>"
    end
    
    def to_s
      inspect
    end
    
    private
    
    def load_history(hl)
      raise "Must be implemented by inheriting class."
    end
    
  end

end
