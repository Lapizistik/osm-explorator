# /home/steink/proj/OSM

Example_queries =  {
  bayreuth: '
(area
  ["boundary"="administrative"]
  ["admin_level"="6"]
  ["name"="Bayreuth"];
)->.a;
(node(area.a);way(area.a);rel(area.a););
out meta;
',
  bamberg_insel: '
(area
  ["boundary"="postal_code"]
  ["postal_code"="96047"];
)->.a;
(node(area.a);way(area.a);rel(area.a););
out meta;
'
}

# openstreetbrowser.org
