# -*- coding: utf-8 -*-

require 'time'

module OSMExplorator

  # A Relation is a geographical object which is identified by its id.
  # It can be part of several regions.
  # It manages all its instances which occured over time. The latest
  # version of this relation is called the current instance.
  class Relation
  
    attr_reader :id
    attr_accessor :current
    
    # Creates a new relation with current as its current instance
    def initialize(current)
      raise "current must not be nil!" if current.nil?
      raise "current must be a NodeInstance!" unless current.kind_of?(RelationInstance)
      
      @current = current
      @id = current.id
      
      @regions = []
      @history = [current]
    end
    
    # Marks this relation as part of the region
    def add_to_region(region)
      raise "region must not be nil!" if region.nil?
      raise "region must be a Region!" unless region.kind_of?(Region)
      
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
    
    def to_s
      return "<Relation: id => #{@id}, "+
             "current => #{@current}, "+
             "history => #{@history.map { |n| n.version }}, "+
             "regions => #{@regions.map { |r| r.id }}>"
    end
    
  end
  
  
  # A RelationInstance is a concrete relation which existed at some point in time.
  # It is identified by its id and version and can refer to a number of
  # nodes, ways or other relations.
  class RelationInstance
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
      
      @id = params[:id].to_i
      @version = params[:version].to_i
      
      @nodes = params[:nodes]
      @ways = params[:ways]
      @relations = params[:relations]
      
      @timestamp = Time.parse(params[:timestamp])
      @changeset = params[:changeset].to_i
      
      @user = params[:user]
      
      @tags = params[:tags]
    end
    
    def to_s
      return "<RelationInstance: id => #{@id}, "+
             "version => #{@version}, "+
             "nodes => #{@nodes.map { |n| n.id }}, "+
             "ways => #{@ways.map { |w| w.id }}, "+
             "relations => #{@relations.map { |r| r.id }}, "+
             "timestamp => #{@timestamp}, "+
             "changeset => #{@changeset}, "+
             "user => #{@user}, "+
             "tags => #{@tags}>"
    end
    
  end

end
