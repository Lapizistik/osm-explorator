# -*- coding: utf-8 -*-

require 'net/http'
require 'nokogiri'
require 'json'

module OSMExplorator

  class OverpassRequest
  
    OVERPASS = URI('http://overpass-api.de/api/interpreter')
      
    class << self
    
      # Does an Overpass API request using query.
      # params can define :format to overwrite json (deprecated),
      # and :uri to overwrite the overpass URI used.
      # Returns all :nodes, :ways and :relations as 
      # a hash with the respective json data.
      def do(query, params={})
        raise "query must not be nil!" if query.nil?
        
        format = params[:format] || 'json'
        uri = params[:uri] || OVERPASS

        query = "[out:#{format}];" + query
        
        warn "Request »#{uri}« with data:"
        warn query
        warn '==== EOT ===='
        
#       response = Net::HTTP.post_form(uri, data: query)
#       json = JSON.parse(response.body)

        data = File.read("json.data")
        json = JSON.parse(data)
        
        return parse_json(json)
      end
      
      private

      # Parses the JSON returned by the overpass request.
      # Returns a hash of the overpass types (:nodes, :ways, :relations)
      # as keys and an array of hashes of the elements as values
      def parse_json(json)
        raise "json must not be nil!" if json.nil?
        
        # TODO / FIXME: confusing code and implicit assumption
        # that elements contains hashes with a "type" key
        # which have either "node", "way" or "relation" as their values.
        return json["elements"].inject({}) { 
          |res, e| 
          t = "#{e["type"]}s".to_sym
          res[t] = [] unless res.keys.include?(t)
          res[t] << symbolize_keys(e)
          res
        }
      end
      
      def symbolize_keys(h)
        Hash[h.map { |k, v| [k.to_sym, v] }]
      end
    end
  
  end

end
