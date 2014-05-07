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
        json[:uid].to_i, json[:tags])

      super(datastore, current)
    end

    private
    
    def load_history(hl)
      his = hl.load_for_way(self)
      # TODO: redundant code (see Node, Way, Relation)
      his.each { |h|
        @history << h unless h.id == current.id &&
                             h.version == current.version
      }
    end
  end
  
  
  # A WayInstance is a concrete way which existed at some point in time.
  # It is identified by its id and version and refers to a number of nodes.
  class WayInstance
    attr_reader :way,
                :id, :version, 
                :nodes,
                :timestamp, :changeset,
                :user,
                :tags
    
    # way must be the parent Way.
    # All other params must have the correct class.
    # uid is resolved to a User object.
    # nodes is an array of nodeids which are resolved
    # to Node objects.
    def initialize(way, id, version, nodeids,
                   timestamp, changeset, uid, tags)
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
      
      @user = way.datastore.user_by_id(uid)
      @user.add_wayInstance(self)
      
      @tags = tags
    end
    
    def inspect
      return "#<#{self.class}:#{object_id*2} "+
             "way => #{@way.object_id*2}, "+
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
