# -*- coding: utf-8 -*-

require 'time'

require 'osmexplorator/osmobject'

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
      
      @current = RelationInstance.new(self,
        json[:id].to_i, json[:version].to_i, json[:members],
        Time.parse(json[:timestamp]), json[:changeset].to_i,
        json[:uid].to_i, json[:user].to_s, json[:tags])

        super(datastore, @current)
    end

    def tags
      @current.tags
    end

    def tag(key)
      @current.tag(key)
    end


    def nodes(filter=@datastore.filter)
      @current.nodes(filter)
    end
    
    def ways(filter=@datastore.filter)
      @current.ways(filter)
    end
    
    def relations(filter=@datastore.filter)
      current.relations(filter)
    end
    
  end
  
  
  # A RelationInstance is a concrete relation which existed at some point in time.
  # It is identified by its id and version and can refer to a number of
  # nodes, ways or other relations.
  class RelationInstance < OSMObjectInstance
    attr_reader :relation,
                :id, :version, 
                :timestamp, :changeset,
                :user
    
    # relation must be the parent Relation.
    # All other params must have the correct class.
    # uid is resolved to a User object.
    # members is an array of hashes with keys 'type', 'ref' and 'role'.
    def initialize(relation, id, version, members,
                   timestamp, changeset, uid, username, tags)
      raise "relation #{relation} must be a "+
            "Relation!" unless relation.kind_of?(Relation)
            
      super()
      
      @relation = relation

      @id = id
      @version = version
      
      ids = {:nodeids => [], :wayids => [], :relationids => []}
      @members = [] # TODO : this is not used anywhere
      
      members.each do |m|
        member = Member.new(m)
        @members << member

        case m['type']
          when "node"
            ids[:nodeids] << member.id
          when "way"
            ids[:wayids] << member.id
          when "relation"
            ids[:relationids] << member.id
        end
      end
      
      @nodes = []
      ids[:nodeids].each do |nid|
        # TODO / FIXME: this should actually do something like
        # relation.datastore.node_by_id(nid)
        n = relation.datastore.nodes[nid]
        @nodes << n
        # TODO: think about making the node know 
        # that it is part of this relation, e.g. 
        # n.add_to_relation_instance(self)
      end
      
      @ways = []
      ids[:wayids].each do |wid|
        # TODO / FIXME: this should actually do something like
        # relation.datastore.way_by_id(nid)
        w = relation.datastore.ways[wid]
        @ways << w
        # TODO: see above
        # w.add_to_relation_instance(self)
      end
      
      @relations = []
      ids[:relationids].each do |rid|
        # TODO / FIXME: this should actually do something like
        # relation.datastore.relation_by_id(nid)
        r = relation.datastore.relations[rid]
        @relations << r
        # TODO: see above
        # r.add_to_relation_instance(self)
      end
      
      @timestamp = timestamp
      @changeset = changeset
      
      @user = relation.datastore.user_by_id(uid, username)
      @user.add_relationInstance(self)
      
      @tags = tags
    end
    
    def nodes(filter=@relation.datastore.filter)
      return FilteredEnumerator.new(@nodes, filter)
    end
    
    def ways(filter=@relation.datastore.filter)
      return FilteredEnumerator.new(@ways, filter)
    end
    
    def relations(filter=@relation.datastore.filter)
      return FilteredEnumerator.new(@relations, filter)
    end
    
    def all_nodes
      return @nodes
    end
    
    def all_ways
      return @ways
    end
    
    def all_relations
      return @relations
    end

    def regions
      @relation.regions
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
  
  class Member
    Types = {'node' => Node, 'way' => Way, 'relation' => Relation}
    
    attr_reader :type, :id, :role

    def initialize(data)
      @type = Types[data['type']]
      @id = data['ref'].to_i
      @role = data['role']
    end
  end

end
