# -*- coding: utf-8 -*-

# This file extends classes by graph functionality

# todo: change this path when we did the gem
require 'util/dotgraph'

module OSMExplorator

  module ParamParser
    def get_filter_and_params(args, params={})
      filter = nil
      args.each do |a|
        case a
        when Filter
          filter = a
        when Hash
          params.merge!(a)
        end
      end
      filter ||= params[:filter] || @filter
      return filter, params
    end 
  end

  class Datastore
    include ParamParser

    def coauthorgraph(*args)
      # ---Redundant
      filter, params = get_filter_and_params(args)
    
      users = params[:users] || @users.values

      geotypes = params[:geotypes] || [:nodes,:ways,:relations]
      geoobjects = params[:geoobjects] || {
        nodes: @nodes.values,
        ways: @ways.values,
        relations: @relations.values
      }
      
      block = params[:block]
      
      recursive = params[:recursive] || false
      if recursive && geotypes != [:ways]
        warn "Only the geotype :ways supports a recursive history!"
      end
      # ---
      
      type = params[:type] || :plain
      newman = (type==:newman)

#     users = users.to_a

      if block
        g = DotGraph.new(users, :directed => false, &block)
      else
        g = DotGraph.new(users, :directed => false) { |n| n.name || '-' }
      end
      
      geotypes.each do |gt|
        items = geoobjects[gt]
        if !items
          warn "coauthorgraph: items for »#{gt.inspect}« missing!"
          items = []
        end
        
        items.each do |item|
          iusers = item.uniq_users(filter, recursive).to_a
          
          l = iusers.length-1 # nr of coauthors on this page...
                    
          iusers.each_with_index do |iu,i|
            (i+1).upto(l) do |j|              
              if newman
                g.link(iu, iusers[j], 1.0/l)
              else
                g.link(iu, iusers[j])
              end
            end
          end
        end
      end
      
      return g
    end

    def directresponsegraph(*args)
      # ---Redundant
      filter, params = get_filter_and_params(args)
    
      users = params[:users] || @users.values

      geotypes = params[:geotypes] || [:nodes,:ways,:relations]
      geoobjects = params[:geoobjects] || {
        nodes: @nodes.values,
        ways: @ways.values,
        relations: @relations.values
      }
      
      block = params[:block]
      
      recursive = params[:recursive] || false
      if recursive && geotypes != [:ways]
        warn "Only the geotype :ways supports a recursive history!"
      end
      # ---
      
      counts = params[:count] || :add
      
      if block
        g = DotGraph.new(users, :directed => true, &block)
      else
        g = DotGraph.new(users, :directed => true) { |n| n.name || '-' }
      end
      
      case counts
      when :add
        # TODO: redundant code for each case
        geotypes.each do |gt|
          items = geoobjects[gt]
          if !items
            warn "directresponsegraph: items for »#{gt.inspect}« missing!"
            items = []
          end
          
          items.each do |item| 
            item.directresponses(filter, recursive).each_pair { |u,to|
              to.each_pair { |v,n| g.link(u,v,n) }
            }
          end
        end
      when :max
        # TODO: see above
        geotypes.each do |gt|
          items = geoobjects[gt]
          if !items
            warn "directresponsegraph: items for »#{gt.inspect}« missing!"
            items = []
          end
          
          items.each do |item| 
            item.directresponses(filter, recursive).each_pair { |u,to|
              to.each_pair { |v,n| g.link(u,v,n,false) }
            }
          end
        end  
      when :page
        # TODO: see above
        geotypes.each do |gt|
          items = geoobjects[gt]
          if !items
            warn "directresponsegraph: items for »#{gt.inspect}« missing!"
            items = []
          end
          
          items.each do |item| 
            item.directresponses(filter, recursive).each_pair { |u,to|
              to.each_pair { |v,n| g.link(u,v,1) }
            }
          end
        end
      else
        warn  "directresponsegraph: unknown counts type '#{counts}'."+
              "No links set!"
      end
      
      return g
    end
    
    def groupresponsegraph(*args)
      # ---Redundant
      filter, params = get_filter_and_params(args)
    
      users = params[:users] || @users.values

      geotypes = params[:geotypes] || [:nodes,:ways,:relations]
      geoobjects = params[:geoobjects] || {
        nodes: @nodes.values,
        ways: @ways.values,
        relations: @relations.values
      }
      
      block = params[:block]
      
      recursive = params[:recursive] || false
      if recursive && geotypes != [:ways]
        warn "Only the geotype :ways supports a recursive history!"
      end
      # ---
      
      counts = params[:count] || :add
      
      if block
        g = DotGraph.new(users, :directed => true, &block)
      else
        g = DotGraph.new(users, :directed => true) { |n| n.name || '-' }
      end
      
      geotypes.each do |gt|
        items = geoobjects[gt]
        if !items
          warn "Items for »#{gt.inspect}« missing!"
          items = []
        end
        
        items.each do |item| 
          item.groupresponses(filter, recursive, false).each { |a,b|
            g.link(a,b)
          }
        end
      end
      
      return g
    end
    
    def interlockingresponsegraph(*args)
      # ---Redundant
      filter, params =  get_filter_and_params(args)
    
      users = params[:users] || @users.values

      geotypes = params[:geotypes] || [:nodes,:ways,:relations]
      geoobjects = params[:geoobjects] || {
        nodes: @nodes.values,
        ways: @ways.values,
        relations: @relations.values
      }
      
      block = params[:block]
      
      recursive = params[:recursive] || false
      if recursive && geotypes != [:ways]
        warn "Only the geotype :ways supports a recursive history!"
      end
      # ---
      
      counts = params[:count] || params[:counts] || :add
      k = params[:k] || 2.0
      gparams = {directed: true}
      if h = params[:gparams] 
        gparams.merge(h)
      end
      
      if block
        g = DotGraph.new(users, gparams, &block)
      else
        g = DotGraph.new(users, gparams) { |n| n.name || '-' }
      end

      case counts
      when :add
        # TODO: redundant code for each case
        geotypes.each do |gt|
          items = geoobjects[gt]
          if !items
            warn "interlockingresponsegraph: items for »#{gt.inspect}« missing!"
            items = []
          end
          
          items.each do |item|
            item.interlockingresponses(filter, recursive).each_pair { |u,to|
              to.each_pair { |v,n| g.link(u,v,n) }
            }
          end
        end
      when :log
        # TODO: see above
        geotypes.each do |gt|
          items = geoobjects[gt]
          if !items
            warn "interlockingresponsegraph: items for »#{gt.inspect}« missing!"
            items = []
          end
          
          items.each do |item| 
            item.interlockingresponses(filter, recursive).each_pair { |u,to|
              to.each_pair { |v,n| g.link(u,v,Math.log(n+1)) }
            }
          end
        end
      when :squares, :rootsqrs
        # TODO: see above
        geotypes.each do |gt|
          items = geoobjects[gt]
          if !items
            warn "interlockingresponsegraph: items for »#{gt.inspect}« missing!"
            items = []
          end
          
          items.each do |item| 
            item.interlockingresponses(filter, recursive).each_pair { |u,to|
              to.each_pair { |v,n| g.link(u,v,n**k) }
            }
          end
        end
        
        if counts == :rootsqrs
          kk = 1.0/k
          g.links.each_value { |l| l.weight = l.weight**kk}
        end
      when :max
        # TODO: see above
        geotypes.each do |gt|
          items = geoobjects[gt]
          if !items
            warn "interlockingresponsegraph: items for »#{gt.inspect}« missing!"
            items = []
          end
          
          items.each do |item| 
            item.interlockingresponses(filter, recursive).each_pair { |u,to|
              to.each_pair { |v,n| g.link(u,v,n,false) }
            }
          end
        end
      when :page
        # TODO: see above
        geotypes.each do |gt|
          items = geoobjects[gt]
          if !items
            warn "interlockingresponsegraph: items for »#{gt.inspect}« missing!"
            items = []
          end
          
          items.each do |item|
            item.interlockingresponses(filter, recursive).each_pair { |u,to|
              to.each_pair { |v,n| g.link(u,v,1) }
            }
          end
        end
      else
        warn "Unknown counts type '#{counts}'. No links set!"
      end
      
      return g
    end
    
    def timedinterlockingresponsegraph(*args)
      # ---Redundant
      filter, params =  get_filter_and_params(args)
    
      users = params[:users] || @users.values

      geotypes = params[:geotypes] || [:nodes,:ways,:relations]
      geoobjects = params[:geoobjects] || {
        nodes: @nodes.values,
        ways: @ways.values,
        relations: @relations.values
      }
      
      block = params[:block]
      
      recursive = params[:recursive] || false
      if recursive && geotypes != [:ways]
        warn "Only the geotype :ways supports a recursive history!"
      end
      # --- 

      gparams = {directed: true}
      if h = params[:gparams] 
        gparams.merge(h)
      end
      
      if block
        g = DotGraph.new(users, gparams, &block)
      else
        g = DotGraph.new(users, gparams) { |n| n.name || '-' }
      end
      
      geotypes.each do |gt|
        items = geoobjects[gt]
        if !items
          warn "timedinterlockingresponsegraph: items for »#{gt.inspect}« missing!"
          items = []
        end
        
        items.each do |item|
          item.timedinterlockingresponses(filter, recursive).each_pair do |s,dt|
            dt.each_pair do |r,t|
              g.timelink(s, r.user, t)
            end
          end
        end
      end
      
      return g
    end
    
  end

  class Region
    include ParamParser

     def coauthorgraph(*args)
       @datastore.coauthorgraph(*graphparams(args))
     end
     
     def directresponsegraph(*args)
      @datastore.directresponsegraph(*graphparams(args))
     end
     
     def groupresponsegraph(*args)
      @datastore.groupresponsegraph(*graphparams(args))
     end
     
     def interlockingresponsegraph(*args)
      @datastore.interlockingresponsegraph(*graphparams(args))
     end
     
     def timedinterlockingresponsegraph(*args)
      @datastore.timedinterlockingresponsegraph(*graphparams(args))
     end

     private
     def graphparams(args)
       filter, params =  get_filter_and_params(args)
       return filter, {
         users: @users,
         geoobjects: {
           nodes: @nodes,
           ways: @ways,
           relations: @relations
         }
       }.merge(params)
     end
  end
  
  class OSMObject
  
    def directresponses(filter=@datastore.filter, recursive=false)
      usersh = Hash.new { |h,k| h[k] = Hash.new(0) }
      graph_history(filter, recursive).each_cons(2) do |a,b|
        usersh[b.user][a.user] += 1
      end
      usersh
    end
    
    def groupresponses(filter=@datastore.filter, recursive=false, compatible=true)
      s = Set.new
      users = graph_history(filter, recursive).collect { |n| n.user }
      while b = users.pop
        users.each { |a| s << [b,a] }
      end
      
      if compatible
        usersh = Hash.new { |h,k| h[k] = Hash.new(0) }
        s.each { |a,b| usersh[a][b] = 1 }
        return usersh
      else
        return s
      end
    end

    def interlockingresponses(filter=@datastore.filter, recursive=false)
      uhs = Hash.new { |h,k| h[k] = Hash.new(0) }
      timedinterlockingresponses(filter, recursive).each_pair { |u,h|
        uh = uhs[u]
        h.each_key { |r| uh[r.user] += 1 }
      }
      
      return uhs
    end

    def timedinterlockingresponses(filter=@datastore.filter, recursive=false)
      latest_users = Hash.new
      usersh = Hash.new { |h,k| h[k] = Hash.new(0) }
        
      graph_history(filter, recursive).each do |r|
        u = r.user
        latest_users.each_pair { |lu,lr| usersh[u][lr] = r.timestamp }
        latest_users[u] = r
      end
        
      return usersh
    end
  end
  
end
