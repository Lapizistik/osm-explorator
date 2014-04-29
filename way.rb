# -*- coding: utf-8 -*-

require 'time'

module OSMExplorator

  # A Way is a geographical object which is identified by its id.
  # It can be part of several regions.
  # It manages all its instances which occured over time. The latest
  # version of this way is called the current instance.
  class Way
    attr_reader :id
    attr_accessor :current
    
    # Creates a new way with current as its current instance
    def initialize(current)
      raise "current must not be nil!" if current.nil?
      raise "current must be a NodeInstance!" unless current.kind_of?(WayInstance)
      
      @current = current
      @id = current.id
      
      @regions = []
      @history = [current]
    end
    
    # Marks this way as part of the region
    def add_to_region(region)
      raise "region must not be nil!" if region.nil?
      raise "region must be a Region!" unless region.kind_of?(Region)
      
      @regions << region
    end
    
    def regions
      return @regions
    end
    
    # Returns a (complete?) history of this way
    def history
      # TODO: load data depending on the timeframe
      return @history
    end
    
    def to_s
      return "<Way: id => #{@id}, "+
             "current => #{@current}, "+
             "history => #{@history.map { |n| n.version }}, "+
             "regions => #{@regions.map { |r| r.id }}>"
    end
    
  end
  
  
  # A WayInstance is a concrete way which existed at some point in time.
  # It is identified by its id and version and refers to a number of nodes.
  class WayInstance
    attr_reader :id, :version, 
                :nodes,
                :timestamp, :changeset,
                :user,
                :tags
    
    # params must be a hash with
    # a numeric :id and :version,
    # :nodes an array of Node objects,
    # :timestamp a timestamp, :changeset an integer,
    # :user a User object and :tags a hash.
    def initialize(params)
      raise "params must not be nil!" if params.nil?
      
      @id = params[:id].to_i
      @version = params[:version].to_i
      
      @nodes = params[:nodes]
      
      @timestamp = Time.parse(params[:timestamp])
      @changeset = params[:changeset].to_i
      
      @user = params[:user]
      
      @tags = params[:tags]
    end
    
    def to_s
      return "<WayInstance: id => #{@id}, "+
             "version => #{@version}, "+
             "nodes => #{@nodes.map { |n| n.id }}, "+
             "timestamp => #{@timestamp}, "+
             "changeset => #{@changeset}, "+
             "user => #{@user}, "+
             "tags => #{@tags}>"
    end
    
  end

end
