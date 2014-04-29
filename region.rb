# -*- coding: utf-8 -*-

module OSMExplorator

  # A Region is a part of the world
  # which contains nodes, ways, relations and the users who
  # created or changed these objects.
  #
  # Regions are managed by Datastore objects.
  class Region
  
    attr_reader :id
    
    # A region must have an id and belong to a datastore
    def initialize(id, datastore, data)
      raise "id must not be nil!" if id.nil?
      raise "datastore must not be nil!" if datastore.nil?
      raise "datastore must be a Datastore!" unless datastore.kind_of?(Datastore)
      
      @id = id
      @datastore = datastore
      
      @nodes = data[:nodes]
      @ways = data[:ways]
      @relations = data[:relations]
      
      @users = []
    
      @nodes.each do |n| 
        n.add_to_region(self)
        @users << n.current.user unless @users.include?(n.current.user)
      end
      
      @ways.each do |w| 
        w.add_to_region(self)
        @users << w.current.user unless @users.include?(w.current.user)
      end
      
      @relations.each do |r|
        r.add_to_region(self)
        @users << r.current.user unless @users.include?(r.current.user)
      end
      
      @users.map { |u| u.add_to_region(self) }
    end
     
    def nodes
      # TODO: replace by enumerator
      return @nodes
    end
     
    def ways
      # TODO: replace by enumerator
      return @ways
    end
    
    def relations
      # TODO: replace by enumerator
      return @relations
    end

    def users
      # TODO: replace by enumerator
      return @users
    end
  
  end
  
end
