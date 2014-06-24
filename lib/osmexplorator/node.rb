# -*- coding: utf-8 -*-

require 'time'
require 'osmexplorator/changetype'

module OSMExplorator

  # A node is a geographical object which is identified by its id.
  # It can be part of several regions.
  # It manages all its instances which occured over time. The latest
  # version of this node is called the current instance.
  class Node < OSMObject

    # Creates a new Node with the given nodeid.
    # This node is loaded from the database from its id unless json
    # is provided when nodeid must be nil.
    # json must be in the form of a Hash containing 
    # the results of an overpass json request.
    def initialize(datastore, nodeid, json=nil)

      raise "datastore #{datastore} must be a "+
            "Datastore!" unless datastore.kind_of?(Datastore)

      @datastore = datastore

      @id = nodeid

      if nodeid.nil?
        @current = NodeInstance.new(self, 
          json[:id].to_i, json[:version].to_i,
          json[:lat].to_f, json[:lon].to_f,
          Time.parse(json[:timestamp]), json[:changeset].to_i,
          json[:uid].to_i, json[:user], json[:tags])
      else
        history
        @current = @history.last if @history
      end

      super(@datastore, @current)
    end
    
    # Retrieves the sequence of NodeInstances (i.e. id and version)
    # in which the location (lat, lon) of the Node changed.
    def history_by_location
      return NodeLocationHistoryEnumerator.new(history)
    end

    # FIXME: make filter-aware!
    # Add some Enumerator!
    def history_by_changetype
      h = history
      return [] unless h.first
      hct = [Changetype::LOCATION | 
             ((h.first.tags.length>0) ? Changetype::TAGS : Changetype::NONE)]
      h.each_cons(2) do |a,b|
        hct << a.changetype(b)
      end
      hct
    end
  end
  
  
  # A NodeInstance is a concrete node which existed at some point in time.
  # It is identified by its id and version.
  class NodeInstance < OSMObjectInstance
    attr_reader :node,
                :id, :version, 
                :lat, :lon,
                :timestamp, :changeset,
                :user
    
    # node must be the parent node of this instance.
    # All other params must have the correct class.
    # uid is resolved to a User object which this instance is added to.
    def initialize(node, id, version, lat, lon,
                   timestamp, changeset, uid, username, tags)
      raise "node #{node} must be a Node!" unless node.kind_of?(Node)
      
      super()
      
      @node = node

      @id = id
      @version = version
      
      @lat = lat
      @lon = lon
      
      @timestamp = timestamp
      @changeset = changeset
      
      @user = node.datastore.user_by_id(uid, username)
      @user.add_nodeInstance(self)
      
      @tags = tags
    end

    def regions
      @node.regions
    end
    
    def inspect
      return "#<#{self.class}:0x#{(object_id*2).to_s(16)} "+
             "node => 0x#{(@node.object_id*2).to_s(16)}, "+
             "id => #{@id}, "+
             "version => #{@version}, "+
             "lat => #{@lat}, "+
             "lon => #{@lon}, "+
             "timestamp => #{@timestamp}, "+
             "changeset => #{@changeset}, "+
             "user => #{@user.id}, "+
             "tags => #{@tags}>"
    end
    
    def to_s
      inspect
    end
    
    # True if the given NodeInstance has the same coordinates,
    # false otherwise or if ni is nil
    def equal_by_location?(ni)
      return false if ni.nil?
      # FIXME: should not silently fail if called with nil
      # So if calling with nil is a bug this should fail! 
      # (fail as early as possible)
      # I am not sure if it is currently called with nil sometimes. 
      # If it is this should change!
      #
      # we do not test whether ni responds to lat and lon…

      ni.lat == @lat && ni.lon == @lon
    end
    
    def changetype(ni)
      ct = Changetype::NONE
      ct |= Changetype::LOCATION  unless ((ni.lat == @lat) && (ni.lon == @lon))
      ct |= Changetype::TAGS      unless (ni.tags == @tags)
      ct
    end
    
  end

end
