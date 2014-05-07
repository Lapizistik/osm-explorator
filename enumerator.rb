# -*- coding: utf-8 -*-

module OSMExplorator

  class OSMEnumerator < Enumerator

    def length # not the most efficient implementation?
      to_a.length
    end

    alias_method :size, :length
  end
  
end
