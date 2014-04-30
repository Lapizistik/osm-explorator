# -*- coding: utf-8 -*-

require 'set'

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
      raise "datastore #{datastore.inspect} must be a Datastore!" unless datastore.kind_of?(Datastore)
      
      @id = id
      @datastore = datastore
      
      @nodes = []
      @ways = []
      @relations = []
      
      @users = Set.new
    end

    def add_node(n)
      @nodes << n
      n.add_to_region(self)
      n.all_users.each do |u| 
        u.add_to_region(self)
        @users << u
      end
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
