# -*- coding: utf-8 -*-

module OSMExplorator

  # A user is a person who created and modified geographical objects,
  # such as nodes, ways and relations. A user can be active in a number
  # of regions.
  class User
  
    attr_reader :id, :name
    
    def initialize(id, name)
      @id = id
      @name = name
      
      @regions = []
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
    
    # Even though they are in fact instances of nodes, ways and relations
    # it is convenient to just call them the nodes, ways and relations.
    alias_method :nodeInstances, :nodes
    alias_method :wayInstances, :ways
    alias_method :relationInstances, :relations
    
    # Marks this user active in this region
    def add_to_region(region)
      raise "region must not be nil!" if region.nil?
      raise "region must be a Region!" if region.kind_of?(Region)
      
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
    
  end

end
