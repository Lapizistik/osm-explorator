# /home/steink/proj/OSM

Example_query = '
(area
  ["boundary"="administrative"]
  ["admin_level"="6"]
  ["name"="Bayreuth"];
)->.a;
(node(area.a);way(area.a);rel(area.a););
out meta;
'
