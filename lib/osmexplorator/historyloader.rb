# -*- coding: utf-8 -*-

require 'pg'
require 'time'

require 'osmexplorator/node'
require 'osmexplorator/way'
require 'osmexplorator/relation'

module OSMExplorator

  class HistoryLoader
  
    # Initializes the historyloader and prepares all SQL statements
    # dbparams see PG::Connection.initialize
    def initialize(dbparams)
      @pgc = PG::Connection.open(dbparams)
      
      loadTagsSQL = "SELECT keyStr, valueStr "+
        "FROM %s "+
        "WHERE %s = $1 AND version = $2"
      
      # -- Node --
      @pgc.prepare("nodeLoad",
        "SELECT nodeid, version, latitude, longitude, "+
        "ts, changeset, uid, username "+
        "FROM Node "+
        "WHERE nodeid = $1 "+
        "ORDER BY version ASC")
      @pgc.prepare("nodeTags", loadTagsSQL % ["NodeTag", "nodeid"])
      
      # -- Way ---
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
          "wayversion = $2 "+
        "ORDER BY id ASC")
      @pgc.prepare("wayTags", loadTagsSQL % ["WayTag", "wayid"])
        
      # -- Relation --
      @pgc.prepare("relationLoad",
        "SELECT relationid, version, ts, changeset, uid, username "+
        "FROM Relation "+
        "WHERE relationid = $1 "+
        "ORDER BY version ASC")
      @pgc.prepare("relationLoadNodes",
        "SELECT roleStr, nodeid "+
        "FROM Relation_Node "+
        "WHERE "+
          "relationid = $1 AND "+
          "relationversion = $2 "+
        "ORDER BY id ASC")
      @pgc.prepare("relationLoadWays",
        "SELECT roleStr, wayid "+
        "FROM Relation_Way "+
        "WHERE "+
          "relationid = $1 AND "+
          "relationversion = $2 "+
        "ORDER BY id ASC")
      @pgc.prepare("relationLoadRelations",
        "SELECT roleStr, relation_reference_id "+
        "FROM Relation_Relation "+
        "WHERE "+
          "relation_referent_id = $1 AND "+
          "relation_referent_version = $2 "+
        "ORDER BY id ASC")
      @pgc.prepare("relationTags", loadTagsSQL % ["RelationTag", "relationid"])
    end
    
    # Returns the maximum (latest) version of the node with the given nodeid
    def max_node_version(nodeid)
      max_version_from_table(nodeid, "nodeid", "Node")
    end
    
    # Returns the maximum (latest) version of the way with the given wayid
    def max_way_version(wayid)
      max_version_from_table(wayid, "wayid", "Way")
    end
    
    # Returns the maximum (latest) version of the relation with the given relationid
    def max_relation_version(relationid)
      max_version_from_table(relationid, "relationid", "Relation")
    end

    # Loads the history of an OSBObject from the database
    def load(osmobj)
      case osmobj
        when Node
          return load_for_node(osmobj)
        when Way
          return load_for_way(osmobj)
        when Relation
          return load_for_relation(osmobj)
        else
          raise "Do not know how to load a #{osmobj.class} history!"
      end
    end

    def load_for_node(node)
      nodesRes = @pgc.exec_prepared("nodeLoad", [node.id])
      
      nodeInstances = []
      nodesRes.each do |nr|
        nid = nr['nodeid'].to_i
        nversion = nr['version'].to_i
        
        tags = load_tags(:node, nid, nversion)
        
        nodeInstances << NodeInstance.new(node,
          nid, nversion,
          nr['latitude'].to_f, nr['longitude'].to_f,
          Time.parse(nr['ts']), nr['changeset'].to_i,
          nr['uid'].to_i, nr['username'].to_s, tags)
      end
      
      return nodeInstances
    end
    
    def load_for_way(way)
      waysRes = @pgc.exec_prepared("wayLoad", [way.id])

      waysTmp = []
      waysRes.each do |wr|
        wid = wr['wayid'].to_i
        wversion = wr['version'].to_i
        
        tags = load_tags(:way, wid, wversion)
      
        waysTmp << {
          :id => wid,
          :version => wversion,
          :timestamp => Time.parse(wr['ts']),
          :changeset => wr['changeset'].to_i,
          :uid => wr['uid'].to_i, :username => wr['username'].to_s,
          :tags => tags} # TODO: tags
      end

      wayInstances = []
      waysTmp.each do |wt|
        wayNodesRes = @pgc.exec_prepared(
        "wayLoadNodes", [wt[:id], wt[:version]])
        
        wt[:nodeids] = wayNodesRes.values.flatten.map { |ni| ni.to_i }

        wayInstances << WayInstance.new(way,
          wt[:id], wt[:version], wt[:nodeids],
          wt[:timestamp], wt[:changeset], 
          wt[:uid], wt[:username], wt[:tags])
      end
      
      return wayInstances
    end
    
    def load_for_relation(relation)
      relationsRes = @pgc.exec_prepared("relationLoad", [relation.id])
                
      relationsTmp = []
      relationsRes.each do |rr|
        rid = rr['relationid'].to_i
        rversion = rr['version'].to_i
        
        tags = load_tags(:relation, rid, rversion)

        relationsTmp << {
          :id => rid,
          :version => rversion,
          :timestamp => Time.parse(rr['ts']),
          :changeset => rr['changeset'].to_i,
          :uid => rr['uid'].to_i, :username => rr['username'].to_s, 
          :tags => tags}
      end
      
      relationInstances = []
      relationsTmp.each do |rt|
        rt[:members] = []
        
        # Nodes
        relationNodesRes = @pgc.exec_prepared(
          "relationLoadNodes", [rt[:id], rt[:version]])
          
        relationNodesRes.each do |rn|
          rt[:members] << {
            'type' => 'node',
            'ref' => rn['nodeid'],
            'role' => rn['roleStr']
          }
        end

        # Ways
        relationWaysRes = @pgc.exec_prepared(
          "relationLoadWays", [rt[:id], rt[:version]])

        relationWaysRes.each do |rw|
          rt[:members] << {
            'type' => 'way',
            'ref' => rw['wayid'],
            'role' => rw['roleStr']
          }
        end
        
        # Relations
        relationRelationsRes = @pgc.exec_prepared(
          "relationLoadRelations", [rt[:id], rt[:version]])

        relationRelationsRes.each do |rr|
          rt[:members] << {
            'type' => 'relation',
            'ref' => rr['relationid'],
            'role' => rr['roleStr']
          }
        end
        
        # Create instance
        relationInstances << RelationInstance.new(relation,
          rt[:id], rt[:version], rt[:members],
          rt[:timestamp], rt[:changeset], 
          rt[:uid], rt[:username], rt[:tags])
      end

      return relationInstances
    end
    
    private
    
    def max_version_from_table(id, iddesc, table)
      res = @pgc.exec(
        "SELECT MAX(version) AS maxVersion "+
        "FROM #{table} "+
        "WHERE #{iddesc} = #{id}")
      
      return res.getvalue(0,0).to_i
    end
    
    def load_tags(osmobj, id, version)
      case osmobj
        when :node
          prepStmt = "nodeTags"
        when :way
          prepStmt = "wayTags"
        when :relation
          prepStmt = "relationTags"
        else
          return {}
      end
      
      warn "loading tags for #{osmobj}: #{id}.#{version}"
      
      tagsRes = @pgc.exec_prepared(prepStmt, [id, version])
      
      return tagsRes.inject({}) { |res, t| res[t['keystr']] = t['valuestr'] ; res }
    end
  end
  
end
