# -*- coding: utf-8 -*-

module OSMExplorator

  # A filter is a class which accepts (rejects) objects
  # which (do not) satisfy a certain property
  class Filter
  
    def allowed?(o)
      return true
    end
    
  end


  class TimeFilter < Filter
  
    # startTime as Time, endTime as Time or nil if unbounded
    def initialize(startTime, endTime=nil)
      endF = endTime ? Float::INFINITY : endTime.to_f
      
      @interval = Range.new(startTime.to_f, endF)
    end
    
    def allowed?(o)
      return @interval.cover?(o.timestamp.to_f)
    end
    
  end
  
end


