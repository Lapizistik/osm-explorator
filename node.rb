# -*- coding: utf-8 -*-

require 'time'

module OSMExplorator

  # A node is a geographical object which is identified by its id.
  # It can be part of several regions.
  # It manages all its instances which occured over time. The latest
  # version of this node is called the current instance.
  class Node
    attr_reader :id
    attr_reader :current
    
    # Creates a new node with current as its current instance
    # params is a Hash containing the results of an overpass json request
    def initialize(params)

      @current = NodeInstance.new(self, 
                                  params[:id].to_i, params[:version].to_i,
                                  params[:lat].to_f, params[:lon].to_f,
                                  Time.parse(params[:timestamp]),
                                  params[:changeset].to_i,
                                  params[:uid].to_i,
                                  params[:tags]
                                  )

      @id = @current.id
      
      @regions = []
      @history = [@current]
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
    
    def to_s
      return "<Node: id => #{@id}, "+
             "current => #{@current}, "+
             "history => #{@history.map { |n| n.version }}, "+
             "regions => #{@regions.map { |r| r.id }}>"
    end
  end
  
  
  # A NodeInstance is a concrete node which existed at some point in time.
  # It is identified by its id and version.
  class NodeInstance
    attr_reader :node,
                :id, :version, 
                :lat, :lon,
                :timestamp, :changeset,
                :user,
                :tags
    
    # json must be a hash with
    # a numeric :id and :version,
    # a :lat and :lon as floats,
    # :timestamp a timestamp, :changeset an integer,
    # :user a User object and :tags a hash.
    def initialize(node, id, version, 
                   lat, lon,
                   timestamp, changeset, uid,
                   tags)
      @node = node

      @id = id
      @version = version
      
      @lat = lat
      @lon = lon
      
      @timestamp = Time.parse(params[:timestamp])
      @changeset = params[:changeset].to_i
      
      @user = node.datastore.user_by_id(uid)
      
      @tags = params[:tags]
    end
    
    def to_s
      return "<NodeInstance: id => #{@id}, "+
             "version => #{@version}, "+
             "lat => #{@lat}, "+
             "lon => #{@lon}, "+
             "timestamp => #{@timestamp}, "+
             "changeset => #{@changeset}, "+
             "user => #{@user}, "+
             "tags => #{@tags}>"
    end
  end

end
