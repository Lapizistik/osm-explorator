# -*- coding: utf-8 -*-

require 'pg'

module OSMExplorator

  class HistoryLoader

    # dbparams see PG::Connection.initialize
    def initialize(dbparams)
      @pgc = PG::Connection.open(dbparams)
    end

    def load_node(nodeid)
      nodesRes = @pgc.exec(
        "SELECT * "+
        "FROM Node "+
        "WHERE nodeid = #{nodeid}")
        
      nodes = nodesRes
      
      return nodes
    end
    
    def load_way(wayid)
      waysRes = @pgc.exec(
        "SELECT * "+
        "FROM Way "+
        "WHERE wayid = #{wayid}")
      
      ways = waysRes
      
      ways.each do |w|
        wayNodesRes = @pgc.exec(
          "SELECT * "+
          "FROM WayNode "+
          "WHERE "+
            "wayid = #{w.id} AND "+
            "wayversion = #{w.version}")
        
        w[:nodes] = wayNodesRes
      end
      
      return ways
    end
    
    def load_relation(relationid)
      relationsRes = @pgc.exec(
        "SELECT * "+
        "FROM Relation "+
        "WHERE relationid = #{relationid}")
                
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
    
  end
  
end
