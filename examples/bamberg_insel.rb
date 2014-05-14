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
cag = bi.coauthorgraph
cag.to_graphviz(cagfile, 'twopi', :pspdf)
puts "[+] Coauthorgraph created and written to '#{cagfile}'."

puts "[!] Creating the directresponsegraph for :bamberg_insel..."
drgfile = "bamberg_insel_directresponsegraph.pdf"
drg = bi.directresponsegraph(recursive: true)
drg.to_graphviz(drgfile, 'twopi', :pspdf)
puts "[+] Directresponsegraph created and written to '#{drgfile}'."

puts "[!] Creating the groupresponsegraph for :bamberg_insel..."
crgfile = "bamberg_insel_groupresponsegraph.pdf"
crg = bi.groupresponsegraph
crg.to_graphviz(crgfile, 'twopi', :pspdf)
puts "[+] Groupresponsegraph created and written to '#{crgfile}'."

puts "[!] Creating the interlockingresponsegraph for :bamberg_insel..."
ilrgfile = "bamberg_insel_interlockingresponsegraph.pdf"
ilrg = bi.interlockingresponsegraph
ilrg.to_graphviz(ilrgfile, 'twopi', :pspdf)
puts "[+] Interlockingresponsegraph created and written to '#{ilrgfile}'."

puts "[!] Creating the timedinterlockingresponsegraph for :bamberg_insel..."
tilrgfile = "bamberg_insel_timedinterlockingresponsegraph.pdf"
tilrg = bi.timedinterlockingresponsegraph
tilrg.to_graphviz(tilrgfile, 'twopi', :pspdf)
puts "[+] Timedinterlockingresponsegraph created and written to '#{tilrgfile}'."
