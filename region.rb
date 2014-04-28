# -*- coding: utf-8 -*-

module OSMExplorator

  # A Region is a part of the world
  # which contains nodes, ways, relations and the users who
  # created or changed these objects.
  #
  # Regions are managed by Datastore objects.
  class Region
   
    # A region must have an id and belong to a datastore
    def initialize(regionid, datastore)
      raise "regionid must not be nil!" if regionid.nil?
      raise "datastore must not be nil!" if datastore.nil?
      
      @regionid = regionid
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
