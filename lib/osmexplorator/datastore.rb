# -*- coding: utf-8 -*-

module OSMExplorator
  DEFAULTCONFIG = {
    trackdir: 'tracks/:uid'  # is this right?
  }

  # A datastore holds all data objects, i.e. is the single point of truth.
  # New nodes, ways, relations and users are added indirectly by 
  # requesting region data via an API, such as overpass.
  class Datastore

    attr_reader :config, :historyloader, :filter
  
    # params[:pg] is the postgresql params hash for DB access. (required)
    # params[:config] can overwrite the default config (e.g. dir
    # to save user files to). (optional)
    def initialize(params={})
      @nodes = {}
      @ways = {}
      @relations = {}
      @users = {}
      @regions = {}

      @config = params[:config] || DEFAULTCONFIG
      @historyloader = HistoryLoader.new(params[:pg])

      @filter = Filter.new
    end
  
    # Adds a new region to this datastore with identifier
    # regionid using an overpass request query to fetch the data.
    def add_region_by_overpass_query(regionid, query)
      raise "regionid must not be nil!" if regionid.nil?
      raise "query must not be nil!" if query.nil?
      raise "»#{regionid}« already exists!" if @regions[regionid]
      
      raw = OverpassRequest.do(query)

      @regions[regionid] = region = Region.new(regionid, self)
      
      raw[:nodes].each do |jnode|
        region.add_node(node_by_json(jnode))
      end
      raw[:ways].each do |jway|
        region.add_way(way_by_json(jway))
      end
      raw[:relations].each do |jrel|
        region.add_relation(relation_by_json(jrel))
      end
      
      return region
    end
  
    # Requests a node by its id. If this node does not exist in the
    # datastore yet, it is added by the HistoryLoader. Beware, as 
    # it is not part of any region then.
    def node_by_id(nid)
      return @nodes[nid] ||= node_by_history(nid)
    end
  
    def nodes
      return @nodes
    end
    
    def ways
      return @ways
    end
    
    def relations
      return @relations
    end
    
    def users
      return @users
    end

    # Beware that if no user with the given uid exists
    # this method will create a new user for you and add it
    # to the datastore.
    def user_by_id(uid, uname=nil)
      @users[uid] ||= User.new(self, uid, uname)
    end
    
    def user_by_name(name)
      @users.values.find {|u| name === u.name }
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
    
    def inspect
      return "#<#{self.class}:0x#{(object_id*2).to_s(16)} "+
             "regions => #{@regions.keys}, "+
             "nodes => <#{@nodes.length} entries>, "+
             "ways => <#{@ways.length} entries>, "+
             "relations => <#{@relations.length} entries>, "+
             "users => <#{@users.length} entries>>"
    end
    
    def to_s
      inspect
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
      @nodes[nid] ||= Node.new(self, nil, jnode)
    end
    
    def way_by_json(jway)
      wid = jway[:id].to_i
      @ways[wid] ||= Way.new(self, jway)
    end
    
    def relation_by_json(jrel)
      rid = jrel[:id].to_i
      @relations[rid] ||= Relation.new(self, jrel)
    end

    def node_by_history(nid)
      @nodes[nid] ||= Node.new(self, nid, nil)
    end
  end

end
