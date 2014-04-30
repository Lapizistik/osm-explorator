# -*- coding: utf-8 -*-

module OSMExplorator

  # A user is a person who created and modified geographical objects,
  # such as nodes, ways and relations. A user can be active in a number
  # of regions.
  class User
  
    attr_reader :id, :name
    
    def initialize(ds, id, name=nil)
      @datastore = ds
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
    
    # Even though they are in fact instances of nodes, ways and relations
    # it is convenient to just call them the nodes, ways and relations.
    #alias_method :nodes, :nodeInstances
    #alias_method :ways, :wayInstances
    #alias_method :relations, :relationInstances

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
      raise "region must not be nil!" if region.nil?
      raise "region must be a Region!" unless region.kind_of?(Region)
      
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
    
    def to_s
      return "<User: id => #{@id}, "+
             "name => #{@name}, "+
             "nodes => #{@nodeInstances.map { |n| n.id }}, "+
             "ways => #{@wayInstances.map { |w| w.id }}, "+
             "relations => #{@relationInstances.map { |r| r.id }}, "+
             "regions => #{@regions.map { |r| r.id }}>"
    end
    
  end

end
