# -*- coding: utf-8 -*-

# $: << "../lib"
# $: << "../util"
# $: << "../"

require 'osmexplorator'

#require_relative 'pglogin'

module PgLogin

  ACCESS = {
    host: "127.0.0.1",
    dbname: "osm",
    user: "osm",
    password: ENV['PGOSMPW'] || File.read('.pgosmpw').chomp
  }

end

def init
puts "[!] Creating a new datastore..."
ds = OSMExplorator::Datastore.new({:pg => PgLogin::ACCESS})
puts "[+] Datastore successfully created."

puts "[!] Creating a new region :bamberg_insel from JSON..."
bi = ds.add_region_by_jsonfile(:bamberg_insel, "/home/jgegenfurtner/osm-explorator/examples/bamberg_insel.json")
puts "[+] New region :bamberg_insel created:"
puts "> Number of nodes:\t #{bi.nodes.length}"
puts "> Number of ways:\t #{bi.ways.length}"
puts "> Number of relations:\t #{bi.relations.length}"

puts "[!] Checking for unusual nodes in :bamberg_insel..."
bi.nodes.each do |n|
  if n.nil?
    puts "[-] A node is nil!"
  else
    n.history.each do |hn|
      if hn.nil?
        puts "[-] NodeInstance of #{n.id} is nil!"
      end
    end
    puts "[-] History is empty for node #{n.id}" if n.history.to_a.empty?
  end
end

puts "[!] Checking for unusual ways in :bamberg_insel..."
bi.ways.each do |w|
  if w.nil?
    puts "[-] A way is nil!"
  else
    w.history.each do |hw|
      if hw.nil?
        puts "[-] WayInstance of #{w.id} is nil!"
      end
    end
    puts "[-] History is empty for way #{w.id}" if w.history.to_a.empty?
  end
end

puts "[!] Checking for unusual relations in :bamberg_insel..."
bi.relations.each do |r|
  if r.nil?
    puts "[-] A relation is nil!"
  else
    r.history.each do |hr|
      if hr.nil?
        puts "[-] RelationInstance of #{r.id} is nil!"
      end
    end
    puts "[-] History is empty for relation #{r.id}" if r.history.to_a.empty?
  end
end
  return ds, bi
end

def graph2pdf(g, filename, params)
  filename = (params[:path] || '.') + '/' + filename
  g.remove_self_links
  g.remove_links(params[:minweight] || 0)
  g.to_graphviz(filename, 'twopi', :pspdf, *(params[:graphviz] || []))
  puts "[+] Graph created and written to '#{filename}'."
end

def create_graphs(region, params={})

  puts "[!] Creating the coauthorgraph for region..."
  graph2pdf(region.coauthorgraph(params[:graph] || {}),
            "bamberg_insel_coauthorgraph.pdf", params)

  
  puts "[!] Creating the directresponsegraph for region..."
  graph2pdf(region.directresponsegraph(params[:graph] || {}),
            "bamberg_insel_directresponsegraph.pdf", params)
  
  puts "[!] Creating the groupresponsegraph for region..."
  graph2pdf(region.groupresponsegraph(params[:graph] || {}),
            "bamberg_insel_groupresponsegraph.pdf", params)
  
  puts "[!] Creating the interlockingresponsegraph for region..."
  graph2pdf(region.interlockingresponsegraph(params[:graph] || {}),
            "bamberg_insel_interlockingresponsegraph.pdf", params)

  puts "[!] Creating the timedinterlockingresponsegraph for region..."
  graph2pdf(region.timedinterlockingresponsegraph(params[:graph] || {}),
            "bamberg_insel_timedinterlockingresponsegraph.pdf", params)
end

# $ds, $bi = init()

# create_graphs($bi, path: '/tmp/graphs', graphviz: ["node[shape=point]", 'edge[penwidth=0.002,color="#90909090",arrowsize=0]',"overlap=false","outputorder=edgesfirst"], minweight:5)
