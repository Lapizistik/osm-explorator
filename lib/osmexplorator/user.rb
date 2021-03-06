# -*- coding: utf-8 -*-

require 'set'

module OSMExplorator

  # A user is a person who created and modified geographical objects,
  # such as nodes, ways and relations. A user can be active in a number
  # of regions.
  class User
    include Comparable

    def self.delayed_attr_reader(*args)
      args.each do |arg|
        self.class_eval %Q{
          def #{arg}
            load_from_osm if !@ready
            @#{arg}
          end
        }            
      end
    end

    attr_reader :id, :name, :datastore
    delayed_attr_reader :description, :tracecount, :changesetcount

    def initialize(datastore, id, name=nil)
      @datastore = datastore
      @id = id
      @name = name
      
      @regions = Set.new
      @nodeInstances = []
      @wayInstances = []
      @relationInstances = []
    end
    
    def nodeInstances
      return OSMEnumerator.new(@nodeInstances)
    end
    
    def wayInstances
      return OSMEnumerator.new(@wayInstances)
    end
    
    def relationInstances
      return OSMEnumerator.new(@relationInstances)
    end
    
    def all_nodeInstances
      return @nodeInstances
    end
    
    def all_wayInstances
      return @wayInstances
    end
    
    def all_relationInstances
      return @relationInstances
    end

    def nodes
      return OSMEnumerator.new(@nodeInstances.map { |ni| ni.node })
    end

    def uniq_nodes
      return OSMEnumerator.new(@nodeInstances.map { |ni| ni.node }.uniq)
    end
    
    def ways
      return OSMEnumerator.new(@wayInstances.map { |wi| wi.way })
    end
    
    def uniq_ways
      return OSMEnumerator.new(@wayInstances.map { |wi| wi.way }.uniq)
    end
    
    def relations
      return OSMEnumerator.new(@relationInstances.map { |ri| ri.relation })
    end
    
    def uniq_relations
      return OSMEnumerator.new(@relationInstances.map { |ri| ri.relation }.uniq)
    end
    
    # Returns all regions in which this user was active
    def regions
      return @regions
    end
    
    def add_nodeInstance(nodeInstance)
      raise "#{nodeInstance} is not a NodeInstance!" unless
            nodeInstance.kind_of?(NodeInstance)    

      @nodeInstances << nodeInstance
    end
    
    def add_wayInstance(wayInstance)
      raise "#{wayInstance} is not a WayInstance!" unless
            wayInstance.kind_of?(WayInstance)
            
      @wayInstances << wayInstance
    end
    
    def add_relationInstance(relationInstance)
      raise "#{relationInstance} is not a RelationInstance!" unless
            relationInstance.kind_of?(RelationInstance)
            
      @relationInstances << relationInstance
    end
    
    # Marks this user active in this region
    def add_to_region(region)
      raise "region #{region} must be a Region!" unless region.kind_of?(Region)
      
      @regions << region
    end
    
    # params[:login] your OSM login name (required)
    # params[:password] your OSM password (required)
    # params[:dir] the directory to save the packed files to (optional)
    # by default this is the directory in the datastore config.
    # Can (must?) contain a ':uid' substring which is replaced by the uid.
    def tracks(params)
      return @tracks if @tracks_loaded
      
      params[:dir] ||= @datastore.config[:trackdir]
      
      # Call name (and not @name) to make sure the name is loaded if 
      # this has not happened yet (name is a delayed_attribute)
      @tracks = UserLoader.load_tracks(@id, name, params)
      
      @tracks_loaded = true

      return @tracks
    end
    
    # Returns the user's activity by counting the number of edits
    # of nodes, ways and relations
    def activity
      return @nodes.length + @ways.length + @relations.length
    end
    
    def inspect
      return "#<#{self.class}:0x#{(object_id*2).to_s(16)} "+
            "datastore => 0x#{(datastore.object_id*2).to_s(16)}, "+
             "id => #{@id}, "+
             "name => #{@name ||"\"\""}, "+
             "nodes => <#{@nodeInstances.length} entries>, "+
             "ways => <#{@wayInstances.length} entries>, "+
             "relations => <#{@relationInstances.length} entries>, "+
             "regions => #{@regions.map { |r| r.id }}>"
    end
    
    def to_s
      inspect
    end
    
    def <=>(u)
      id <=> u.id
    end

    def ready?
      @ready
    end

    private 

    def load_from_osm
      if info = UserLoader.load_info(@id)
      
        @name = info[:name]
        @description = info[:description]
        @tracecount = info[:tracecount]
        @changesetcount = info[:changesetcount]
        
        @ready = true
      else
        @name ||= ""
        @description = "[!] Download of user #{@id} did not work! [!]"
        @tracecount = nil
        @changesetcount = nil
        @ready = :broken
      end
    end
  
  end

end
