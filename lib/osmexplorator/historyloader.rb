# -*- coding: utf-8 -*-

require 'pg'
require 'time'

module OSMExplorator

  class HistoryLoader

    # dbparams see PG::Connection.initialize
    def initialize(dbparams)
      @pgc = PG::Connection.open(dbparams)
      
      @pgc.prepare("nodeLoad",
        "SELECT nodeid, version, latitude, longitude, "+
        "ts, changeset, uid, username "+
        "FROM Node "+
        "WHERE nodeid = $1 "+
        "ORDER BY version ASC")
      
      @pgc.prepare("wayLoad",
        "SELECT wayid, version, ts, changeset, uid, username "+
        "FROM Way "+
        "WHERE wayid = $1 "+
        "ORDER BY version ASC")
      @pgc.prepare("wayLoadNodes",
        "SELECT nodeid "+
        "FROM Way_Node "+
        "WHERE "+
        "wayid = $1 AND "+
        "wayversion = $2")
        
      @pgc.prepare("relationLoad",
        "SELECT relationid, version, ts, changeset, uid, username "+
        "FROM Relation "+
        "WHERE relationid = $1 "+
        "ORDER BY version ASC")
      @pgc.prepare("relationLoadNodes",
        "SELECT nodeid "+
        "FROM Relation_Node "+
        "WHERE "+
        "relationid = $1 AND "+
        "relationversion = $2")
      @pgc.prepare("relationLoadWays",
        "SELECT wayid "+
        "FROM Relation_Way "+
        "WHERE "+
          "relationid = $1 AND "+
          "relationversion = $2")
      @pgc.prepare("relationLoadRelations",
        "SELECT relation_reference_id "+
        "FROM Relation_Relation "+
        "WHERE "+
          "relation_referent_id = $1 AND "+
          "relation_referent_version = $2")
    end
    
    def max_node_version(nodeid)
      max_version_from_table(nodeid, "nodeid", "Node")
    end
    
    def max_way_version(wayid)
      max_version_from_table(wayid, "wayid", "Way")
    end
    
    def max_relation_version(relationid)
      max_version_from_table(relationid, "relationid", "Relation")
    end

    def load(osmobj)
      case osmobj
      when Node
        load_for_node(osmobj)
      when Way
        load_for_way(osmobj)
      when Relation
        load_for_relation(osmobj)
      else
        raise "Do not know how to load a #{osmobj.class} history!"
      end
    end

    def load_for_node(node)
      nodesRes = @pgc.exec_prepared("nodeLoad", [node.id])
      
      nodes = []
      nodesRes.each do |nr|
        nodes << NodeInstance.new(node,
          nr['nodeid'].to_i, nr['version'].to_i,
          nr['latitude'].to_f, nr['longitude'].to_f,
          Time.parse(nr['ts']), nr['changeset'].to_i,
          nr['uid'].to_i, nr['username'].to_s, {})  # TODO: tags
      end
      
      return nodes
    end
    
    def load_for_way(way)
      waysRes = @pgc.exec_prepared("wayLoad", [way.id])

      waysTmp = []
      waysRes.each do |wr|
        waysTmp << {
          :id => wr['wayid'].to_i,
          :version => wr['version'].to_i,
          :timestamp => Time.parse(wr['ts']),
          :changeset => wr['changeset'].to_i,
          :uid => wr['uid'].to_i, :username => wr['username'].to_s,
          :tags => {}} # TODO: tags
      end

      ways = []
      waysTmp.each do |wt|
        wayNodesRes = @pgc.exec_prepared(
        "wayLoadNodes", [wt[:id], wt[:version]])
        
        wt[:nodeids] = wayNodesRes.values.flatten.map { |ni| ni.to_i }

        ways << WayInstance.new(way,
          wt[:id], wt[:version], wt[:nodeids],
          wt[:timestamp], wt[:changeset], 
          wt[:uid], wt[:username], wt[:tags])
      end
      
      return ways
    end
    
    def load_for_relation(relation)
      relationsRes = @pgc.exec_prepared("relationLoad", [relation.id])
                
      relationsTmp = []
      relationsRes.each do |rr|
        relationsTmp << {
          :id => rr['relationid'].to_i,
          :version => rr['version'].to_i,
          :timestamp => Time.parse(rr['ts']),
          :changeset => rr['changeset'].to_i,
          :uid => rr['uid'].to_i, :username => rr['username'].to_s, 
          :tags => {}} # TODO: tags
      end
      
      relations = []
      relationsTmp.each do |rt|
      
        relationNodesRes = @pgc.exec_prepared(
          "relationLoadNodes", [rt[:id], rt[:version]])
        rt[:nodeids] = relationNodesRes.values.flatten.map { |ni| ni.to_i }
        
        relationWaysRes = @pgc.exec_prepared(
          "relationLoadWays", [rt[:id], rt[:version]])
        rt[:wayids] = relationWaysRes.values.flatten.map { |wi| wi.to_i }
        
        relationRelationsRes = @pgc.exec_prepared(
          "relationLoadRelations", [rt[:id], rt[:version]])
        rt[:relationids] = relationRelationsRes.values.flatten.map { |ri| ri.to_i }
        
        relations << RelationInstance.new(relation,
          rt[:id], rt[:version], 
          rt[:nodeids], rt[:wayids], rt[:relationids],
          rt[:timestamp], rt[:changeset], 
          rt[:uid], rt[:username], rt[:tags])
      end

      return relations
    end
    
    private
    
    def max_version_from_table(id, iddesc, table)
      res = @pgc.exec(
        "SELECT MAX(version) AS maxVersion "+
        "FROM #{table} "+
        "WHERE #{iddesc} = #{id}")
      
      return res.getvalue(0,0).to_i
    end
    
  end
  
end
