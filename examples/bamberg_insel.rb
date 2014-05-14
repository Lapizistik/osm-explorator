# -*- coding: utf-8 -*-

$: << "../lib"
$: << "../util"
$: << "../"

require 'osmexplorator'

require_relative 'pglogin'

puts "[!] Creating a new datastore..."
ds = OSMExplorator::Datastore.new({:pg => PgLogin::ACCESS})
puts "[+] Datastore successfully created."

puts "[!] Creating a new region :bamberg_insel from JSON..."
bi = ds.add_region_by_jsonfile(:bamberg_insel, "bamberg_insel.json")
puts "[+] New region :bamberg_insel created:"
puts "> Number of nodes:\t #{bi.nodes.length}"
puts "> Number of ways:\t #{bi.ways.length}"
puts "> Number of relations:\t #{bi.relations.length}"

puts "[!] Checking for nil nodes in :bamberg_insel..."
bi.nodes.each do |n|
  if n.nil?
    puts "[-] Node is nil!"
  else
    n.history.each do |hn|
      if hn.nil?
        puts "[-] NodeInstance of #{n.id} is nil!"
      end
    end
    puts "[-] History is empty for node #{n.id}" if n.history.to_a.empty?
  end
end

puts "[!] Checking for nil ways in :bamberg_insel..."
bi.ways.each do |w|
  if w.nil?
    puts "[-] Way is nil!"
  else
    w.history.each do |hw|
      if hw.nil?
        puts "[-] WayInstance of #{w.id} is nil!"
      end
    end
    puts "[-] History is empty for way #{w.id}" if w.history.to_a.empty?
  end
end

puts "[!] Checking for nil relations in :bamberg_insel..."
bi.relations.each do |r|
  if r.nil?
    puts "[-] Relation is nil!"
  else
    r.history.each do |hr|
      if hr.nil?
        puts "[-] RelationInstance of #{r.id} is nil!"
      end
    end
    puts "[-] History is empty for relation #{r.id}" if r.history.to_a.empty?
  end
end

puts "[!] Creating the coauthorgraph for nodes..."
cagfile = "bamberg_insel_coauthorgraph.pdf"
cag = bi.coauthorgraph()
cag.to_graphviz(cagfile, 'twopi', :pspdf)
puts "[+] Coauthorgraph created and "+
     "written to '#{cagfile}'."
