# -*- coding: utf-8 -*-

module OSMExplorator

  # A region is a part of the world
  # which contains nodes, ways, relations and users.
  #
  # Regions are managed by Datastore objects.
  class Region
   
    # A region must have an id and belong to a datastore
    def initialize(id, datastore)
      raise "id must not be nil!" if id.nil?
      raise "datastore must not be nil!" if datastore.nil?
      
      @id = id
      @datastore = datastore
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
