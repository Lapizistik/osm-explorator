# -*- coding: utf-8 -*-

require 'set'

module OSMExplorator

  # A Region is a part of the world
  # which contains nodes, ways, relations and the users who
  # created or changed these objects.
  #
  # Regions are managed by Datastore objects.
  class Region
  
    attr_reader :id, :datastore
    
    # A region must have an id and belong to a datastore
    def initialize(id, datastore, data)
      raise "id must not be nil!" if id.nil?
      raise "datastore #{datastore} must be a "+
            "Datastore!" unless datastore.kind_of?(Datastore)
      
      @id = id
      @datastore = datastore
      
      @nodes = []
      @ways = []
      @relations = []
      
      @users = Set.new
    end

    # Adds a node to this region and implicitely the author of this node
    # if the user is not a member of the authors of this region yet
    def add_node(node)
      @nodes << node
      node.add_to_region(self)
      
      node.all_users.each do |u| 
        u.add_to_region(self)
        @users << u
      end
    end
    
    # Adds a way to this region and implicitely the author of this way
    # if the user is not a member of the authors of this region yet
    def add_way(way)
      @ways << way
      way.add_to_region(self)
      
      way.all_users.each do |u|
        u.add_to_region(self)
        @users << u
      end
    end
    
    # Adds a relation to this region and implicitely the author of this relation
    # if the user is not a member of the authors of this region yet
    def add_relation(relation)
      @relations << relation
      relation.add_to_region(self)
      
      relation.all_users.each do |u|
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
  
    def inspect
      return "<#{self.class}:#{object_id*2} "+
             "id => #{@id}, "+
             "datastore => #{@datastore}, "+
             "nodes => <#{@nodes.length} entries>, "+
             "ways => <#{@ways.length} entries>, "+
             "relations => <#{@relations.length} entries>, "+
             "users => #{@users}>"
    end
    
    def to_s
      inspect
    end
    
  end
  
end
