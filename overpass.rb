# -*- coding: utf-8 -*-

require 'net/http'
require 'nokogiri'

module OSMExplorator

  class OverpassRequest
  
    OVERPASS = URI('http://overpass-api.de/api/interpreter')
      
    class << self
    
      # Does an Overpass API request using query.
      # params can define :format to overwrite xml,
      # and :uri to overwrite the overpass URI used.
      # Returns all :nodes, :ways and :relations as 
      # a hash with the respective data.
      def do(query, params={})
        # Do a HTTP request
        
        # Parse result
        
        # Return nodes, ways and relations
        
        raise "query must not be nil!" if query.nil?
        
        format = params[:format] || 'xml'
        uri = params[:uri] || OVERPASS

        query = "[out:#{format}];" + query
        
        warn "Request »#{uri}« with data:"
        warn query
        warn '==== EOT ===='
        
        response = Net::HTTP.post_form(uri, data: query)
        
        res = {}
        
        res[:nodes] =  parse_xml(response.body, "node")
        res[:ways] = parse_xml(response.body, "way")
        res[:relations] = parse_xml(response.body, "relation")
        
        return res
      end
      
      # xml is the XML data structure
      # type is the path within the structure
      def parse_xml(xml, type)
        raise "xml must not be nil!" if xml.nil?
        xml = Nokogiri::XML(xml) unless xml.respond_to?(:xpath)
        
        return xml.xpath("osm/#{type}")
      end
      
    end
  
  end

end
