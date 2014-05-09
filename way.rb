# -*- coding: utf-8 -*-

require 'time'

module OSMExplorator

  # A Way is a geographical object which is identified by its id.
  # It can be part of several regions.
  # It manages all its instances which occured over time. The latest
  # version of this way is called the current instance.
  class Way < OSMObject
  
    # Creates a new way with current as its current instance
    # json is a Hash containing the results of an overpass json request
    def initialize(datastore, json)
      raise "datastore #{datastore} must be a "+
            "Datastore!" unless datastore.kind_of?(Datastore)

      @datastore = datastore
      
      @current = WayInstance.new(self,
        json[:id].to_i, json[:version].to_i,
        json[:nodes].map { |ni| ni.to_i },
        Time.parse(json[:timestamp]), json[:changeset].to_i,
        json[:uid].to_i, json[:user].to_s, json[:tags])

      super(datastore, current)
    end

  end
  
  
  # A WayInstance is a concrete way which existed at some point in time.
  # It is identified by its id and version and refers to a number of nodes.
  class WayInstance
    attr_reader :way,
                :id, :version,
                :timestamp, :changeset,
                :user,
                :tags
    
    # way must be the parent Way.
    # All other params must have the correct class.
    # uid is resolved to a User object.
    # nodes is an array of nodeids which are resolved
    # to Node objects.
    def initialize(way, id, version, nodeids,
                   timestamp, changeset, uid, username, tags)
      raise "way #{way} must be a Way!" unless way.kind_of?(Way)
      
      @way = way

      @id = id
      @version = version
      
      @nodes = []
      nodeids.each do |nid|
        n = way.datastore.nodes[nid]
        @nodes << n
        # TODO: think about making the node know 
        # that it is part of this WayInstance, e.g. 
        # n.add_to_way_instance(self)
      end
      
      @timestamp = timestamp
      @changeset = changeset
      
      @user = way.datastore.user_by_id(uid, username)
      @user.add_wayInstance(self)
      
      @tags = tags
    end
    
    def all_nodes
      return @nodes
    end
    
    def nodes
      return OSMEnumerator.new(@nodes)
    end
    
    def inspect
      return "#<#{self.class}:0x#{(object_id*2).to_s(16)} "+
             "way => 0x#{(@way.object_id*2).to_s(16)}, "+
             "id => #{@id}, "+
             "version => #{@version}, "+
             "nodes => <#{@nodes.length} entries>, "+
             "timestamp => #{@timestamp}, "+
             "changeset => #{@changeset}, "+
             "user => #{@user.id}, "+
             "tags => #{@tags}>"
    end
    
    def to_s
      inspect
    end
    
  end

end
