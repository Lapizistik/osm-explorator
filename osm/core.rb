# -*- coding: utf-8 -*-

module OSMExplorator
  
  # = Basic class holding all the OSM objects currently available
  #
  # 
  class Datastore

    # fetch nodes by overpass request and add them to Region and Datastore 
    def new_region_by_overpass(name, ql)
      raise "»#{name}« already exists!" if @regions[name]
      @regions[name] = Region.new(name, self) # add some request code
    end

    # dump everything
    def save(filename)
      File.open(filename,'w') { |f| f << Marshal.dump(self) }
    end

    class < self
      def load(filename)
        Marshal.load(File.read(filename))
      end
    end
  end

  # certain view on a selection of OSM data
  class Region
    # has, nodes, ways, relations, users and at least one default filter
  end

  class Filter
  end

  class Node
  end

  class Way
  end

  class Relation
  end

  class User
    def initialize
      # add some user data

      @nodeinstances = []
      @wayinstances = []
      @relationinstances = []
    end

    # the unfiltered array of all nodes of the user
    def allnodeinstances
      @nodeinstances
    end

    def nodeinstances(params=@datastore.filter)
      f = params2filter(params)
      NodesInstancesEnumerator.new(@nodeinstancess, f)
    end

    def nodes(params=@datastore.filter)
      f = params2filter(params)
      NodesFromInstancesEnumerator.new(@nodeinstancess, f)
    end
  end

  class NodeInstance
  end

  class WayInstance
  end

  class RelationInstance
  end

  class BasicEnumerator < Enumerator

    def size
      l = 0
      each { l += 1 }
      l
    end
    alias length size

    # whether a given object is seen through this view. To be
    # overwritten in subclasses.
    def allowed?(i)
      true
    end

    # returns the first object in this view. 
    #
    # Equal to but much more efficient than #to_a.first
    #
    # Please note that this gives no predictable results on Enumerators of
    # Set and other non-ordered Enumerables
    def first
      find { |i| allowed?(i)}
    end

    # returns the last object in this view. 
    #
    # Equal to but much more efficient than #to_a.last 
    # (for ordered Enumerables)
    #
    # Please note that this gives no predictable results on Enumerators of
    # Set and other non-ordered Enumerables
    def last
      if @list.respond_to?(:reverse_each)
        @list.reverse_each { |i| return i if allowed?(i) }
        return nil
      else
        first
      end
    end
  end

  # A view on an empty list singleton.
  class EmptyEnumerator < BasicEnumerator
    include Singleton
    def initialize
      @list = []
    end
  end

  class GenericEnumerator < BasicEnumerator
    def initialize(&block)
      @block = block
    end
    def allowed?(obj)
      @block.call(obj)
    end
  end

  class NodesEnumerator < BasicEnumerator
  end

  class WaysEnumerator < BasicEnumerator
  end

  class RelationsEnumerator < BasicEnumerator
  end

  class UsersEnumerator < BasicEnumerator
  end

  class UsersFromInstancesEnumerator < BasicEnumerator
    def initialize(instances, filter)
      super() do |y|
        instances.each do |i|
          y.yield(i.user) if true # some complicated evaluation on filter
        end
      end
    end
  end

  class < self

    def params2filter(params)
      if params.kind_of(Filter)
        params
      else
        params[:filter] || default
      end
    end
  end
end
