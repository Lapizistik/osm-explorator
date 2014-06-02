# -*- coding: utf-8 -*-

module OSMExplorator

  class OSMEnumerator < Enumerator
   
    # Whether a given object is seen through this view. Should be 
    # overwritten by subclasses to achieve the desired functionality.
    def allowed?(o)
      return true
    end

    # Returns the first object in this view. 
    #
    # Semantically the same as #to_a.first but much more efficient. 
    #
    # Please note that this gives unpredictable results on Enumerators of
    # Set and other non-ordered Enumerables.
    def first
      return find { |i| allowed?(i) }
    end

    # Returns the last object in this view. 
    #
    # Semantically the same as #to_a.last but much more efficient. 
    #
    # Please note that this gives unpredictable results on Enumerators of
    # Set and other non-ordered Enumerables
    def last
      if @list.respond_to?(:reverse_each)
        @list.reverse_each { |i| return i if allowed?(i) }
        return nil
      else
        return first
      end
    end
    
    def length
      l = 0
      each { l += 1 }
      return l
    end

    alias_method :size, :length
    
  end
  
  # A generic enumerator which calls block to decide whether
  # an object may pass through this view. block must return
  # a boolean value.
  class GenericEnumerator < OSMEnumerator
  
    def initialize(objs, &block)
      @block = block
      
      super() do |y|
        objs.each do |o|
          y.yield(o) if allowed?(o)
        end
      end
    end
    
    def allowed?(o)
      return @block.call(o)
    end
    
  end
  
  # An enumerator which calls the given filter.allowed?
  # method for deciding whether a particular object is allowed
  # to pass through this view.
  class FilteredEnumerator < OSMEnumerator
  
    def initialize(objs, filter)
      @filter = filter
      
      super() do |y|
        objs.each do |o|
          # Broken! Should be filter.allowed_something? ???
          y.yield(o) if allowed?(o)
        end
      end
    end
    
    def allowed?(o)
      return @filter.nil? ? true : @filter.allowed?(o) 
    end
    
  end
  
  # An enumerator which filters the passed node history
  # in such a way that only changes in a NodeInstance's location
  # are yielded, repetition of a location is allowed, 
  # e.g. [(n1,v1,0,0), (n1,v3,1,0), (n1,v4,0,0)]
  class NodeLocationHistoryEnumerator < OSMEnumerator
  
    def allowed?(o)
      if o.equal_by_location?(@cur)
        return false
      else
        @cur = o
        return true
      end
    end
    
  end
  
end
