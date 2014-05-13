# -*- coding: utf-8 -*-


module OSMExplorator

  module ParamParser
    def get_filter_and_params(args, params={})
      filter = nil
      args.each do |a|
        case a
        when Filter
          filter = a
        when Hash
          params.merge(a)
        end
      end
      filter ||= params[:filter] || @filter
      return filter, params
    end 
  end

  class Datastore
    include ParamParser

    def coauthorgraph(*args)
      filter, params =  get_filter_and_params(args)
      
      type = params[:type] || :plain
      newman = (type==:newman)

      users = params[:users] || @users.values

      geotypes = params[:geotypes] || [:nodes,:ways,:relations]
      geoobjects = params[:geoobjects] || {
        nodes: @nodes.values,
        ways: @ways.values,
        relations: @relations.values
      }

#        users = users.to_a

      if block
        g = DotGraph.new(users, :directed => false, &block)
      else
        g = DotGraph.new(users, :directed => false) { |n| n.name||'-' }
      end
      
      geotypes.each do |gt|
        items = geoobjects[gt]
        if !items
          warn "Items for »#{gt.inspect}« missing!"
          items = []
        end
        items.each do |item|
          iusers = item.uniq_users(filter).to_a
          
          l = iusers.length-1 # nr of coauthors on this page...
          
          iusers.each_with_index do |iu,i|
            (i+1).upto(l) do |j|
              if newman
                g.link(iu,iusers[j], 1.0/l)
              else
                g.link(iu,iusers[j])
              end
            end
          end
        end
      end
      g

    end
  end

  class Region
    include ParamParser

     def coauthorgraph(*args)
       @datastore.coauthorgraph(*graphparams(args))
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
end
