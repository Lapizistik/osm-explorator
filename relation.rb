# -*- coding: utf-8 -*-

require 'time'

module OSMExplorator

  # A Relation is a geographical object which is identified by its id.
  # It can be part of several regions.
  # It manages all its instances which occured over time. The latest
  # version of this relation is called the current instance.
  class Relation < OSMObject
  
    # Creates a new relation with current as its current instance
    # json is a Hash containing the results of an overpass json request
    def initialize(datastore, json)
      raise "datastore #{datastore} must be a "+
            "Datastore!" unless datastore.kind_of?(Datastore)

      @datastore = datastore
      
      json[:nodes] ||= []
      json[:ways] ||= []
      json[:relations] ||= []
      
      @current = RelationInstance.new(self,
        json[:id].to_i, json[:version].to_i,
        json[:nodes].map { |ni| ni.to_i },
        json[:ways].map { |wi| wi.to_i },
        json[:relations].map { |ri| ri.to_i },
        Time.parse(json[:timestamp]), json[:changeset].to_i,
        json[:uid].to_i, json[:tags])

        super(datastore, current)
    end

    private
    
    def load_history(hl)
      his = hl.load_for_relation(self)
      # TODO: redundant code (see Node, Way, Relation)
      his.each { |h|
        @history << h unless h.id == current.id &&
                             h.version == current.version
      }
    end
    
  end
  
  
  # A RelationInstance is a concrete relation which existed at some point in time.
  # It is identified by its id and version and can refer to a number of
  # nodes, ways or other relations.
  class RelationInstance
    attr_reader :relation,
                :id, :version, 
                :nodes, :ways, :relations,
                :timestamp, :changeset,
                :user,
                :tags
    
    # way must be the parent Way.
    # All other params must have the correct class.
    # uid is resolved to a User object.
    # nodes is an array of nodeids which are resolved
    # to Node objects.
    def initialize(relation, id, version,
                   nodeids, wayids, relationids,
                   timestamp, changeset, uid, tags)
      raise "relation #{relation} must be a "+
            "Relation!" unless relation.kind_of?(Relation)
      
      @relation = relation

      @id = id
      @version = version
      
      @nodes = []
      nodeids.each do |nid|
        n = relation.datastore.nodes[nid]
        @nodes << n
        # TODO: think about making the node know 
        # that it is part of this relation, e.g. 
        # n.add_to_relation_instance(self)
      end
      
      @ways = []
      wayids.each do |wid|
        w = relation.datastore.ways[wid]
        @ways << w
        # TODO: see above
        # w.add_to_relation_instance(self)
      end
      
      @relations = []
      relationids.each do |rid|
        r = relation.datastore.relations[rid]
        @relations << r
        # TODO: see above
        # r.add_to_relation_instance(self)
      end
      
      @timestamp = timestamp
      @changeset = changeset
      
      @user = relation.datastore.user_by_id(uid)
      @user.add_relationInstance(self)
      
      @tags = tags
    end
    
    def inspect
      return "#<#{self.class}:0x#{(object_id*2).to_s(16)} "+
             "relation => 0x#{(@relation.object_id*2).to_s(16)}, "+
             "id => #{@id}, "+
             "version => #{@version}, "+
             "nodes => <#{@nodes.length} entries>, "+
             "ways => <#{@ways.length} entries>, "+
             "relations => <#{@relations.length} entries>, "+
             "timestamp => #{@timestamp}, "+
             "changeset => #{@changeset}, "+
             "user => #{@user}, "+
             "tags => #{@tags}>"
    end
    
    def to_s
      inspect
    end
  end

end
