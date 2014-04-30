# -*- coding: utf-8 -*-

module OSMExplorator

  # A user is a person who created and modified geographical objects,
  # such as nodes, ways and relations. A user can be active in a number
  # of regions.
  class User

    attr_reader :id, :name, :datastore
    
    def initialize(datastore, id, name=nil)
      @datastore = datastore
      @id = id
      @name = name
      
      @regions = []
      @nodeInstances = []
      @wayInstances = []
      @relationInstances = []
    end
  
    def nodeInstances
      return @nodeInstances
    end
    
    def wayInstances
      return @wayInstances
    end
    
    def relationInstances
      return @relationInstances
    end
    
    def nodes
      # Change to enumerator!
      @nodeInstances.collect { |ni| ni.node }
    end

    def uniq_nodes
      # Change to enumerator!
      @nodeInstances.collect { |ni| ni.node }.uniq
    end
    
    # Marks this user active in this region
    def add_to_region(region)
      raise "region #{region} must be a Region!" unless region.kind_of?(Region)
      
      @regions << region
    end
    
    # Returns all regions in which this user was active
    def regions
      return @regions
    end
    
    # Returns the user's activity by counting the number of edits
    # of nodes, ways and relations
    def activity
      return @nodes.length + @ways.length + @relations.length
    end
    
    def inspect
      return "#<#{self.class}:#{object_id*2} "+
            "datastore => #{datastore}, "+
             "id => #{@id}, "+
             "name => #{@name}, "+
             "nodes => <#{@nodeInstances.length} entries>, "+
             "ways => <#{@wayInstances.length} entries>, "+
             "relations => <#{@relationInstances.length} entries>, "+
             "regions => #{@regions.map { |r| r.id }}>"
    end
    
    def to_s
      inspect
    end
  end

end
