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
      max_version_from_table(nodeid, "wayid", "Way")
    end
    
    def max_relation_version(relationid)
      max_version_from_table(nodeid, "relationid", "Relation")
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
    
    def load_relation(relation)
      relationsRes = @pgc.exec(
        "SELECT * "+
        "FROM Relation "+
        "WHERE relationid = #{relation.id}")
                
      relations = relationsRes
      
      relations.each do |r|
        relationNodesRes = @pgc.exec(
          "SELECT * "+
          "FROM Relation_Node "+
          "WHERE "+
            "relationid = #{r.id} AND "+
            "relationversion = #{r.version}")
        r[:nodes] = relationNodesRes
                
        relationWaysRes = @pgc.exec(
          "SELECT * "+
          "FROM Relation_Way "+
          "WHERE "+
            "relationid = #{r.id} AND "+
            "relationversion = #{r.version}")
        r[:ways] = relationWaysRes
        
        relationRelationsRes = @pgc.exec(
          "SELECT * "+
          "FROM Relation_Relation "+
          "WHERE "+
            "relation_referent_id = #{r.id} AND "+
            "relation_referent_version = #{r.version}")
        r[:relations] = relationRelationsRes
      end

      return relations
    end
    
    private
    
    def max_version_from_table(id, iddesc, table)
      res = @pgc.exec(
        "SELECT MAX(version) AS maxVersion"+
        "FROM #{table} "+
        "WHERE #{iddesc} = #{id}")
      
      return res[0]['maxVersion']
    end
    
  end
  
end
