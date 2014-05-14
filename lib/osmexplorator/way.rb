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

      super(datastore, @current)
    end

    def history_by_nodes(filter=@datastore.filter)
      his = history(filter).to_a
      
      # Step 1:
      # Remove all way versions which only have tag-changes in them
      # as we are not interested in tag-changes.
      wayHistory = his[1..-1].inject([his.first]) { |res, wi|
        wn = wi.nodes.map {|n| n.id}.uniq.sort
        rn = res.last.nodes.map {|n| n.id}.uniq.sort
        (wn == rn) ? res : res << wi
      }
      
      # Step 2:
      # Find the time intervals between the versions
      
      # Create the interval sequence
      timeIntervals = wayHistory[0..-2].zip(wayHistory[1..-1])
      
      # Convert the sequence to ranges
      timeIntervals.map! { |i| 
        Range.new(i[0].timestamp.to_f, i[1].timestamp.to_f, true) # exclude
      }
      
      # Add the last version with an unbounded range
      timeIntervals << Range.new(wayHistory[-1].timestamp.to_f, Float::INFINITY)
      
      # Step 3:
      # Find the subhistory of every wayInstance defined by the location
      # changes of its referencd nodes      
      wayHistory_nodeLocHis = {}
      
      # For all way versions
      wayHistory.length.times do |i|
      
        # Initialize the subhistory
        wayHistory_nodeLocHis[i] = []
        
        # For all nodes references by this way
        wayHistory[i].nodes(filter).each do |n|
        
          # Find all node location changes
          nodeLocHis = n.history_by_location.to_a
                    
          # Reduce to the nodes whose location changed 
          # in the interval of interest
          nodeLocHis.select! { |nl|
            timeIntervals[i].cover?(nl.timestamp.to_f)
          }
          
          # Add the location changes of this node in the
          # location changes of all nodes of this wayInstance version
          wayHistory_nodeLocHis[i] += nodeLocHis
        end
        
        # Sort the subhistory by timestamp
        wayHistory_nodeLocHis[i].sort! { |n1, n2|
          n1.timestamp <=> n2.timestamp
        }
      end
      
      # Step 4:
      # Create a handy datastructure that describes all versions
      # { real_version => {
      #     :way => <WayInstance>,
      #     :nodeChange => <NodeInstance>
      # } }
      # where the value of :nodeChange is either nil or the NodeInstance
      # which changed its location.
      result = {}
      counter = 1
      
      wayHistory.length.times do |i|
        result[counter] = {
          :way => wayHistory[i],
          :nodeChange => nil
        }
        
        counter += 1
        
        wayHistory_nodeLocHis[i].each do |changed_node|
          result[counter] = {
            :way => wayHistory[i],
            :nodeChange => changed_node
          }
          
          counter += 1
        end
      end
      
      return result
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
        n = way.datastore.node_by_id(nid)
        # TODO: think about cascading the region to the node
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
    
    def nodes(filter=@way.datastore.filter)
      return FilteredEnumerator.new(@nodes, filter)
    end
    
    def all_nodes
      return @nodes
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
