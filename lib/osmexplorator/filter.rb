# -*- coding: utf-8 -*-

module OSMExplorator

  # A filter is a class which accepts (rejects) objects
  # which (do not) satisfy a certain property
  class Filter
  
    def allowed?(o)
      return true
    end
    
    def rejected?(o)
      return false
    end
    
  end
  
end

