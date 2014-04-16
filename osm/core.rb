# -*- coding: utf-8 -*-
# -*- codeing: utf-8 -*-

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
  end

  class NodeInstance
  end

  class WayInstance
  end

  class RelationInstance
  end

  class BasicView
    include Enumerable

    # Creates a new View. 
    # _list_ is some kind of Enumerable, e.g. an Array or Set.
    def initialize(list, filter)
      @list = list
      @filter = filter
    end
    def size
      l = 0
      each { l += 1 }
      l
    end
    alias length size
    def each &block    
      @list.each { |i| block.call(i) if allowed?(i) }
    end

    # whether a given object is seen through this view. To be
    # overwritten in subclasses.
    def allowed?(i)
      true
    end

    # returns the first object in this view. 
    #
    # Equal to but much more efficient than #to_a.first
    #
    # Please note that this gives no predictable results on Views of
    # Set and other non-ordered Enumerables
    def first
      find { |i| allowed?(i)}
    end

    # returns the last object in this view. 
    #
    # Equal to but much more efficient than #to_a.last 
    # (for ordered Enumerables)
    #
    # Please note that this gives no predictable results on Views of
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
  class EmptyView < BasicView
    include Singleton
    def initialize
      @list = []
    end
  end

  class NodesView < BasicView
  end

  class WaysView < BasicView
  end

  class RelationsView < BasicView
  end

  class UsersView < BasicView
  end

end
