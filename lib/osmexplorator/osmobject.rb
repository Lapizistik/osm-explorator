# -*- coding: utf-8 -*-

module OSMExplorator

  # An OSM Object, such as a Node, Way or Relation
  class OSMObject
    attr_reader :id, :current, :datastore
    
    def initialize(datastore, current)
      raise "datastore #{datastore} must be a "+
            "Datastore!" unless datastore.kind_of?(Datastore)

      @datastore = datastore
      
      if current
        @id = current.id
        @history = [current] unless @history
        @current = current
      end
      
      @regions = []
    end
    
    def add_to_region(region)
      raise "region #{region} must be a "+
            "Region!" unless region.kind_of?(Region)

      @regions << region
    end

    def regions
      @regions
    end


    def tags
      @current.tags
    end

    def tag(key)
      @current.tag(key)
    end
    
    # Returns a filtered history of this node as an enumerator.
    def history(filter=@datastore.filter)
      if !@loaded
        his = @datastore.historyloader.load(self).sort_by { |i| i.version }
        
        if @current
          # Make sure that the current version is not overwritten by
          # the versions from the database.
          his.delete_if { |i| i.version == @current.version }
          @history += his
        else
          @history = his
        end
        
        @loaded = true


        # FIXME: we should not need this, but something is wrong
        repair_history!
=begin
        warn  "Incomplete history for #{self.class} with id = #{self.id}: "+
          "missing #{history_missing_n} version(s)!" unless history_complete?
=end
      end
      
      return FilteredEnumerator.new(@history, filter)
    end

    # FIXME: we should not need this!
    def repair_history!
      @history.sort_by! { |i| i.version }
      @current = @history.last
    end

    # returns a history for dotgraph creation
    def graph_history(filter=@datastore.filter, recursive=false)
      if recursive
        recursive_history(filter)
      else
        history(filter)
      end
    end

    # default implementation, to be overwritten by Way (and Relation?)
    def recursive_history(filter=@datastore.filter)
      history(filter)
    end

    # True if all versions are available
    # false if some versions of this object are missing.
    # Use history_missing to find out which ones.
    def history_complete?
      return history_missing_n == 0
    end
    
    # Returns the number of instances of this OSMobject which
    # are missing in the history.
    def history_missing_n
      return history_missing.length
    end
    
    # Returns an array with all version numbers of this object
    # which are missing in the history.
    def history_missing
      @history ||= history
      
      if @current
        return (1..@current.version).to_a - @history.map { |o| o.version }
      else
        return []
      end
    end
    
    def all_users(filter=@datastore.filter)
      return history(filter).map { |oi| oi.user }
    end
    
    def uniq_users(filter=@datastore.filter, recursive=false)
      if recursive
        return recursive_history.map { |oi| oi.user }.uniq
      else
        # TODO: this is the same as all_users()
        # Create all_users_recursive() for the above case?
        return history.map { |oi| oi.user }.uniq
      end
    end
       
    def inspect
      return "#<#{self.class}:0x#{(object_id*2).to_s(16)} "+
             "id => #{@id}, "+
             "datastore => 0x#{(@datastore.object_id*2).to_s(16)}, "+
             "history => #{@history.map { |oi| oi.version }}, "+
             "regions => #{@regions.map { |r| r.id }}, "+
             "current => 0x#{(@current.object_id*2).to_s(16)}>"
    end
    
    def to_s
      inspect
    end

    
  end

  class OSMObjectInstance
  
    attr_reader :tags
    
    def initialize()
      @tags = {}
    end
  
    def tag(key)
      @tags && @tags[key]
    end
    
  end

end
