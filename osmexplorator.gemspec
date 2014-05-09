Gem::Specification.new do |s|
	s.name		=	'osmexplorator'
	s.version	=	'0.1.0'
	s.date		=	'2014-05-08'
	s.summary	=	'A library for doing social network analysis on Open Street Map data'
	s.description	=	'A library for doing social network analysis on Open Street Map data'
	s.authors	=	["Juergen Gegenfurtner", "Klaus Stein"]
	s.email		=	'jgegenfurtner@googlemail.com'
	s.files		=	[ "lib/osmexplorator.rb",
                "lib/osmexplorator/datastore.rb",
                "lib/osmexplorator/node.rb",
                "lib/osmexplorator/osmobject.rb",
                "lib/osmexplorator/region.rb",
                "lib/osmexplorator/userloader.rb",
                "lib/osmexplorator/way.rb",
                "lib/osmexplorator/historyloader.rb",
                "lib/osmexplorator/osmenumerator.rb",
                "lib/osmexplorator/overpass.rb",
                "lib/osmexplorator/relation.rb",
                "lib/osmexplorator/user.rb",
              ]
	s.homepage	=	'https://github.com/Lapizistik/osm-explorator'
	s.license	=	'GPL'
end
