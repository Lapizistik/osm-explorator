# -*- coding: utf-8 -*-

require 'net/http'
require 'nokogiri'

module OSMExplorator

  class OverpassRequest
  
    OVERPASS = URI('http://overpass-api.de/api/interpreter')
      
    class << self
    
      # Does an Overpass API request using query.
      # params can define :format to overwrite json,
      # and :uri to overwrite the overpass URI used.
      # Returns all :nodes, :ways and :relations as 
      # Node, Way and Relation objects in a hash.
      def do(query, params={})
        # Do a HTTP request
        
        # Parse result
        
        # Return nodes, ways and relations
        
        raise "query must not be nil!" if query.nil?
        
        format = params[:format] || 'json'
        uri = params[:uri] || OVERPASS

        query = "[out:#{format}];" + query
        
        warn "Request »#{uri}« with data:"
        warn query
        warn '==== EOT ===='
        
        response = Net::HTTP.post_form(uri, data: query)
        
        res = {}
        
        res[:nodes] = xml_to_type(response, "node")
        res[:ways] = xml_to_type(response, "way")
        res[:relations] = xml_to_type(response, "relation")
        
        return res
      end
      
      # xml is the XML data structure
      # type is the path within the structure
      # c is the class used for construction from the xml data
      def xml_to_type(xml, type, c)
        raise "xml must not be nil!" if xml.nil?
        xml = Nokogiri::XML(xml) unless xml.respond_to?(:xpath)
        
        es = []
        
        xml.xpath("osm/#{type}").each do |e|
          cur = Module.const_get("#{type}Instance".capitalize).new(e)
          es << Module.const_get(type.capitalize).new(cur)
        end
        
        return es
      end
      
    end
  
  end

end
