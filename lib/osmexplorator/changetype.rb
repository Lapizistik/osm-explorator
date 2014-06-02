module OSMExplorator
  module Changetype
    NONE     = 0b0000
    LOCATION = 0b0001
    REFS     = 0b0010
    TAGS     = 0b1000
    
    SPATIAL  = LOCATION | REFS

    String = {
      NONE     => 'none',
      LOCATION => 'location',
      REFS     => 'refs',
      TAGS     => 'tags',
      SPATIAL  => 'spatial'
    }
    Chr = {
      NONE     => '-',
      LOCATION => 'l',
      REFS     => 'r',
      TAGS     => 't',
      SPATIAL  => 's'
    }
  end
end
