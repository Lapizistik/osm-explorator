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
    def initialize(id, datastore)
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
    
    def nodes(filter=@datastore.filter)
      return FilteredEnumerator.new(@nodes, filter)
    end
     
    def ways(filter=@datastore.filter)
      return FilteredEnumerator.new(@ways, filter)
    end
    
    def relations(filter=@datastore.filter)
      return FilteredEnumerator.new(@relations, filter)
    end

    def users(filter=@datastore.filter)
      return FilteredEnumerator.new(@users, filter)
    end

    def all_relations
      @relations
    end

    # Adds a node to this region and implicitely the author of this node
    # if the user is not a member of the authors of this region yet
    def add_node(node)
      @nodes << node
      node.add_to_region(self)
      
# =begin
      node.all_users.each do |u| 
        u.add_to_region(self)
        @users << u
      end
# =end
#      @users << node.current.user
    end
    
    # Adds a way to this region and implicitely the author of this way
    # if the user is not a member of the authors of this region yet
    def add_way(way)
      @ways << way
      way.add_to_region(self)
      
# =begin
      way.all_users.each do |u|
        u.add_to_region(self)
        @users << u
      end
# =end
#      @users << way.current.user
    end
    
    # Adds a relation to this region and implicitely the author of this relation
    # if the user is not a member of the authors of this region yet
    def add_relation(relation)
      @relations << relation
      relation.add_to_region(self)
      
# =begin
      relation.all_users.each do |u|
        u.add_to_region(self)
        @users << u
      end
# =end
#      @users << relation.current.user
    end
         
    def inspect
      return "<#{self.class}:0x#{(object_id*2).to_s(16)} "+
             "id => #{@id}, "+
             "datastore => 0x#{(@datastore.object_id*2).to_s(16)}, "+
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
