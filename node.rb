# -*- coding: utf-8 -*-

module OSMExplorator

  # A node is a geographical object which is identified by its nodeid.
  # It can be part of several regions.
  # It manages all its instances which occured over time. The latest
  # version of this node is called the current instance.
  class Node
    attr_reader :nodeid
    attr_accessor :current
    
    # Creates a new node with current as its current instance
    def initialize(current)
      raise "current must not be nil!" if current.nil?
      raise "current must be a NodeInstance!" unless current.kind_of?(NodeInstance)
      
      @current = current
      @nodeid = current.nodeid
      @regions = []
    end
    
    # Marks this node as part of the region
    def add_to_region(region)
      raise "region must not be nil!" if region.nil?
      raise "region must be a Region!" unless region.kind_of?(Region)
      
      @regions << region
    end
    
    def regions
      return @regions
    end
    
    # Returns a (complete?) history of this node
    def history
      # TODO: load data depending on the timeframe
      return @history
    end
  end
  
  
  # A NodeInstance is a concrete node which existed at some point in time.
  # It is identified by its id and version.
  class NodeInstance
    attr_reader :nodeid, :version, 
                :lat, :lon,
                :timestamp, :changeset,
                :user,
                :tags
    
    # params must be a hash with
    # a numeric :nodeid and :version,
    # a :lat and :lon as floats,
    # :timestamp a timestamp, :changeset an integer,
    # :user a User object and :tags a hash.
    def initialize(params)
      raise "params must not be nil!" if params.nil?
      
      @nodeid = params[:nodeid]
      @version = params[:version]
      
      @lat = params[:lat]
      @lon = params[:lon]
      
      @timestamp = params[:timestamp]
      @changeset = params[:changeset]
      
      @user = params[:user]
      
      @tags = params[:tags]
    end
    
  end

end
