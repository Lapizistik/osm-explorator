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
        u = n.current.user
        @users << u unless @users.include?(u)
        u.nodes << n.current unless u.nodes.include?(n.current)
      end
      
      @ways.each do |w| 
        w.add_to_region(self)      
        u = w.current.user
        @users << u unless @users.include?(u)
        u.ways << w.current unless u.ways.include?(w.current)
      end
      
      @relations.each do |r|
        r.add_to_region(self)
        u = r.current.user
        @users << u unless @users.include?(u)
        u.relations << r.current unless u.relations.include?(r.current)
      end
      
      @users.each { |u| u.add_to_region(self) }
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
  
    def to_s
      return "<Region: id => #{@id}, "+
             "datastore => ..., "+
             "nodes => #{@nodes.map { |n| n.id }}, "+
             "ways => #{@ways.map { |w| w.id }}, "+
             "relations => #{@relations.map { |r| r.id }}, "+
             "users => #{@users.map { |u| u.id }}>"
    end
    
  end
  
end
