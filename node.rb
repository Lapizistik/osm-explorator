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
        json[:uid].to_i, json[:tags])

      super(datastore, current)
    end
    
    def history(hl=nil)
      load_history(hl) unless @loaded
      
      @loaded = true
      
      return @history
    end
    
    # Retrieves the sequence of NodeInstances (i.e. id and version)
    # in which the location (lat, lon) of the Node changed.
    def history_by_location_change
      # TODO: Does the history need to be sorted?
      # If yes, make sure the history is sorted upon loading?
      history.sort! { |x, y| x.version <=> y.version }
      
      # Consider using ni.equal_by_location? somehow
      # if this does not do what you want
      history.uniq { |ni| [ni.lat, ni.lon] }
    end

    private
    
    def load_history(hl)
      his = hl.load_for_node(self)
      his.each { |h| 
        @history << h unless  h.id == current.id && 
                              h.version == current.version
      }
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
                   timestamp, changeset, uid, tags)
      raise "node #{node} must be a Node!" unless node.kind_of?(Node)
      
      @node = node

      @id = id
      @version = version
      
      @lat = lat
      @lon = lon
      
      @timestamp = timestamp
      @changeset = changeset
      
      @user = node.datastore.user_by_id(uid)
      @user.add_nodeInstance(self)
      
      @tags = tags
    end
    
    def inspect
      return "#<#{self.class}:#{object_id*2} "+
             "node => #{@node.object_id*2}, "+
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
    # false otherwise
    def equal_by_location?(ni)
      ni.lat == @lat && ni.lon == @lon
    end
    
  end

end
