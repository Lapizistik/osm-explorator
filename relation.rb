# -*- coding: utf-8 -*-

module OSMExplorator

  # A Relation is a geographical object which is identified by its relationid.
  # It can be part of several regions.
  # It manages all its instances which occured over time. The latest
  # version of this relation is called the current instance.
  class Way
    attr_reader :id
    attr_accessor :current
    
    # Creates a new relation with current as its current instance
    def initialize(current)
      raise "current must not be nil!" if current.nil?
      raise "current must be a NodeInstance!" if current.kind_of?(RelationInstance)
      
      @current = current
      @id = current.id
      @regions = []
    end
    
    # Marks this relation as part of the region
    def add_to_region(region)
      raise "region must not be nil!" if region.nil?
      raise "region must be a Region!" if region.kind_of?(Region)
      
      @regions << region
    end
    
    def regions
      return @regions
    end
    
    # Returns a (complete?) history of this relation
    def history
      # TODO: load data depending on the timeframe
      return @history
    end
  end
  
  
  # A RelationInstance is a concrete relation which existed at some point in time.
  # It is identified by its id and version and can refer to a number of
  # nodes, ways or other relations.
  class WayInstance
    attr_reader :id, :version, 
                :nodes, :ways, :relations,
                :timestamp, :changeset,
                :user,
                :tags
    
    # params must be a hash with
    # a numeric :id and :version,
    # :nodes an array of Node objects,
    # :ways an array of Way objects,
    # :relations an array of Relation objects,
    # :timestamp a timestamp, :changeset an integer,
    # :user a User object and :tags a hash.
    def initialize(params)
      raise "params must not be nil!" if params.nil?
      
      @id = params[:id]
      @version = params[:version]
      
      @nodes = params[:nodes]
      @ways = params[:ways]
      @relations = params[:relations]
      
      @timestamp = params[:timestamp]
      @changeset = params[:changeset]
      
      @user = params[:user]
      
      @tags = params[:tags]
    end
    
  end

end
