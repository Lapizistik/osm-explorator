# -*- coding: utf-8 -*-

module OSMExplorator

  class OSMEnumerator < Enumerator

    def length # not the most efficient implementation?
      to_a.length
    end

    alias_method :size, :length
  end
  
  class NodeLocationHistoryEnumerator < OSMEnumerator
  
    def initialize(history)
      cur = nil
      
      super() do |y|
        history.each do |h|
          unless h.equal_by_location?(cur)
            y.yield(h)
            cur = h
          end
        end
      end
    end
    
  end
  
end
