# -*- coding: utf-8 -*-

module OSMExplorator

  # A datastore holds all data objects, i.e. is the single point of truth.
  # New nodes, ways, relations and users are added indirectly by 
  # requesting region data via an API, such as overpass.
  class Datastore
  
    def initialize
      @nodes = {}
      @ways = {}
      @relations = {}
      @users = {}
      @regions = {}
    end
  
    # Adds a new region to this datastore with identifier
    # regionid using an overpass request query to fetch the data.
    def add_region_by_overpass_query(regionid, query)
      raise "regionid must not be nil!" if regionid.nil?
      raise "query must not be nil!" if query.nil?
      raise "»#{regionid}« already exists!" if @regions[regionid]
      
      raw = OverpassRequest.do(query)

      region = Region.new(regionid, self)
      
      raw[:nodes].each do |jnode|
        region.add_node(node_by_json(jnode))
      end
      raw[:ways].each do |jway|
        regiondata[:ways] << (@ways[jway[:id]] || add_way_from_json(jway))
      end
      raw[:relations].each do |jrel|
        regiondata[:relations] << (@relations[jrel[:id]] || add_relation_from_json(jrel))
      end
      
      return add_region(regionid, regiondata)
    end
    
    # Adds a new region to this datastore with identifier
    # regionid and a data-hash consisting of :nodes with Node objects,
    # :ways with Way objects and :relations with Relation objects
    def add_region(regionid, data)
      raise "regionid must not be nil!" if regionid.nil?
      raise "data must not be nil!" if data.nil?
      raise "»#{regionid}« already exists!" if @regions[regionid]
      
      @regions[regionid] = r = Region.new(regionid, self, data)

      return r
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

    def user_by_id(uid, uname=nil)
      @users[uid] ||= User.new(self, uid, uname)
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
    
    def to_s
      return "<Datastore: regions => #{@regions.keys}, "+
             "nodes => #{@nodes.keys}, "+
             "ways => #{@ways.keys}, "+
             "relations => #{@relations.keys}, "+
             "users => #{@users.keys}>"
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
    
    private
    
    def node_by_json(jnode)
      nid = jnode[:id].to_i
      @nodes[nid] ||= Node.new(jnode)
    end
    



    def add_way_from_json(way)
      way[:user] = @users[way[:uid]] || add_user(way[:uid], way[:user])
      
      current = WayInstance.new(way)
      @ways[way[:id]] = Way.new(current)
      
      return @ways[way[:id]]
    end
    
    def add_relation_from_json(rel)
      rel[:user] = @users[rel[:uid]] || add_user(rel[:uid], rel[:user])
      
      current = RelationInstance.new(rel)
      @relations[rel[:id]] = Relation.new(current)
      
      return @relations[rel[:id]]
    end
    
    def add_user(userid, username)
      @users[userid] = User.new(userid, username)
      
      return @users[userid]
    end
  end

end
