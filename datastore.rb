# -*- coding: utf-8 -*-

require_relative 'overpass'

module OSMExplorator

  # A datastore holds all data objects, i.e. is the single point of truth.
  # New nodes, ways, relations and users are added indirectly by 
  # requesting region data via an API, such as overpass.
  class Datastore
  
    # Adds a new region to this datastore with identifier
    # regionid using an overpass request query to fetch the data.
    def add_region_by_overpass(regionid, query)
      raise "regionid must not be nil!" if regionid.nil?
      raise "query must not be nil!" if query.nil?
      raise "»#{regionid}« already exists!" if @regions[regionid]
      
      @regions[regionid] = Region.new(regionid, self)
      
      # add some request code
      
      # add nodes/ways/relations/users which do not yet exist
      # to the datastore
      
      # give nodes/ways/relations/users objects from the datastore
      # to the region
      
      return @regions[regionid]
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
    
    def regions
      return @regions
    end
    
    # Returns the region identified by regionid, 
    # possibly nil if regionid does not exist in this datastore
    def region(regionid)
      raise "regionid must not be nil!" if regionid.nil?
      
      return @regions[regionid]
    end
    
    # Saves this datastore object to the filepath specified
    def save(filepath)
      raise "filepath must not be nil!" if filepath.nil?
      
      File.open(filepath,'w') { |f| f << Marshal.dump(self) }
    end

    # Class methods
    class << self
    
      # Returns a Datastore object loaded from the filepath specified
      def load(filepath)
        raise "filepath must not be nil!" if filepath.nil?
        
        datastore = Marshal.load(File.read(filepath))
        
        return datastore
      end
      
    end
    
  end

end
