# -*- coding: utf-8 -*-

require 'time'

module OSMExplorator

  # A node is a geographical object which is identified by its id.
  # It can be part of several regions.
  # It manages all its instances which occured over time. The latest
  # version of this node is called the current instance.
  class Node < OSMObject

    # Creates a new node with current as its current instance
    # json is a Hash containing the results of an overpass json request
    def initialize(datastore, json)
      raise "datastore #{datastore} must be a "+
            "Datastore!" unless datastore.kind_of?(Datastore)

      @datastore = datastore

      @current = NodeInstance.new(self, 
        json[:id].to_i, json[:version].to_i,
        json[:lat].to_f, json[:lon].to_f,
        Time.parse(json[:timestamp]), json[:changeset].to_i,
        json[:uid].to_i, json[:user], json[:tags])

      super(datastore, current)
    end
    
    # Retrieves the sequence of NodeInstances (i.e. id and version)
    # in which the location (lat, lon) of the Node changed.
    def history_by_location
      return NodeLocationHistoryEnumerator.new(history)
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
    
    # node must be the parent node of this instance.
    # All other params must have the correct class.
    # uid is resolved to a User object which this instance is added to.
    def initialize(node, id, version, lat, lon,
                   timestamp, changeset, uid, username, tags)
      raise "node #{node} must be a Node!" unless node.kind_of?(Node)
      
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

      ni.lat == @lat && ni.lon == @lon
    end
    
  end

end