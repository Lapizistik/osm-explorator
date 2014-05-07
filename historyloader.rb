# -*- coding: utf-8 -*-

require 'pg'
require 'time'

module OSMExplorator

  class HistoryLoader

    # dbparams see PG::Connection.initialize
    def initialize(dbparams)
      @pgc = PG::Connection.open(dbparams)
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

    def load_for_node(node)
      nodesRes = @pgc.exec(
        "SELECT nodeid, version, latitude, longitude, "+
        "ts, changeset, uid "+
        "FROM Node "+
        "WHERE nodeid = #{node.id}")
      
      nodes = []  
      nodesRes.each do |nr|
        nodes << NodeInstance.new(node,
          nr['nodeid'].to_i, nr['version'].to_i,
          nr['latitude'].to_f, nr['longitude'].to_f,
          Time.parse(nr['ts']), nr['changeset'].to_i,
          nr['uid'].to_i, {})  # TODO: tags
      end
      
      return nodes
    end
    
    def load_for_way(way)
      waysRes = @pgc.exec(
        "SELECT wayid, version, ts, changeset, uid "+
        "FROM Way "+
        "WHERE wayid = #{way.id}")

      waysTmp = []
      waysRes.each do |wr|
        waysTmp << {
          :id => wr['wayid'].to_i,
          :version => wr['version'].to_i,
          :timestamp => Time.parse(wr['ts']),
          :changeset => wr['changeset'].to_i,
          :uid => wr['uid'].to_i,
          :tags => {}} # TODO: tags
      end

      ways = []
      waysTmp.each do |wt|
        wayNodesRes = @pgc.exec(
          "SELECT nodeid "+
          "FROM Way_Node "+
          "WHERE "+
            "wayid = #{wt[:id]} AND "+
            "wayversion = #{wt[:version]}")
        
        wt[:nodeids] = wayNodesRes.values.flatten.map { |ni| ni.to_i }

        ways << WayInstance.new(way,
          wt[:id], wt[:version], wt[:nodeids],
          wt[:timestamp], wt[:changeset], wt[:uid], wt[:tags])
      end
      
      return ways
    end
    
    def load_for_relation(relation)
      relationsRes = @pgc.exec(
        "SELECT relationid, version, ts, changeset, uid "+
        "FROM Relation "+
        "WHERE relationid = #{relation.id}")
                
      relationsTmp = []
      relationsRes.each do |rr|
        relationsTmp << {
          :id => rr['relationid'].to_i,
          :version => rr['version'].to_i,
          :timestamp => Time.parse(rr['ts']),
          :changeset => rr['changeset'].to_i,
          :uid => rr['uid'].to_i,
          :tags => {}} # TODO: tags
      end
      
      relations = []
      relationsTmp.each do |rt|
        relationNodesRes = @pgc.exec(
          "SELECT nodeid "+
          "FROM Relation_Node "+
          "WHERE "+
            "relationid = #{rt[:id]} AND "+
            "relationversion = #{rt[:version]}")
        rt[:nodeids] = relationNodesRes.values.flatten.map { |ni| ni.to_i }
        
        relationWaysRes = @pgc.exec(
          "SELECT wayid "+
          "FROM Relation_Way "+
          "WHERE "+
            "relationid = #{rt[:id]} AND "+
            "relationversion = #{rt[:version]}")
        rt[:wayids] = relationWaysRes.values.flatten.map { |wi| wi.to_i }
        
        relationRelationsRes = @pgc.exec(
          "SELECT relation_reference_id "+
          "FROM Relation_Relation "+
          "WHERE "+
            "relation_referent_id = #{rt[:id]} AND "+
            "relation_referent_version = #{rt[:version]}")
        rt[:relationids] = relationRelationsRes.values.flatten.map { |ri| ri.to_i }
        
        relations << RelationInstance.new(relation,
          rt[:id], rt[:version], 
          rt[:nodeids], rt[:wayids], rt[:relationids],
          rt[:timestamp], rt[:changeset], rt[:uid], rt[:tags])
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
