# -*- coding: utf-8 -*-

require 'set'
require 'net/http'
require 'nokogiri'
require 'open-uri'

module OSMExplorator

  class UserLoader
    TRACKDIR = 'tracks/:uid'
    API = 'http://api.openstreetmap.org/api/0.6'
    USERTRACESPAGE = "http://www.openstreetmap.org/user/%s/traces/page/%i"
  
    class << self
    
      # uid = the user id
      # params[:server] the API URI to use (optional)
      # Returns a hash with keys :name, :account_created, :description,
      # :imgurl, changesetcount and :tracecount
      def load_info(uid, params={})
        begin
          userdata = (get_user_data(uid)/'osm/user').first
        rescue OpenURI::HTTPError => e
          warn "User #{uid} not found: " + e.message
          return
        end
        realid = userdata['id'].to_i
        raise "Wrong id error: #{uid} != #{realid}" if uid != realid
        
        user = {}
        user[:name] = userdata['display_name']
        user[:account_created] = userdata['account_created']
        user[:description] = (userdata/'description').inner_text
        if img = (userdata/'img').first
          user[:imgurl] = img['href']
        end
        if changesets = (userdata/'changesets').first
          user[:changesetcount] = changesets['count'].to_i
        end
        if traces = (userdata/'traces').first
          user[:tracecount] = traces['count'].to_i
        end
        
        return user
      end
      
      # uid = the user id
      # name = the user name
      # params[:dir] the directory to save the packed files to (optional)
      # params[:login] your OSM login name (required)
      # params[:password] your OSM password (required)
      def load_tracks(uid, name, params)
        trackdir = create_trackdir(uid, params[:dir] || TRACKDIR)
        
        login = params[:login] || 'xdjkx'
        password = params[:password] or raise 'no password given!'
        
        FileUtils.mkdir_p trackdir

        i = 1
        tids = Set.new
        regexp = %r|<a href="/user/#{name}/traces/([0-9]+)">|
        begin
          url = URI.encode(USERTRACESPAGE % [name, i])
          begin
            tt = open(url).read.scan(regexp).flatten
            tids += tt
            i += 1
          rescue OpenURI::HTTPError => e
            warn "Got error #{e} on #{url}"
            tt = []
          end
        end until tt.empty?

        tids.each do |tid|
          filename = File.join(trackdir, tid+'.gpx.bz2')
          unless File.exists?(filename)
            begin
              url = API + "/gpx/#{tid}/data"
              gpxdata = open(url, 
                             http_basic_authentication:[login, password]).read
              File.open(filename,'w') { |f| f << gpxdata }
            rescue OpenURI::HTTPError => e
              warn "Got error #{e} on #{url}"
            end
          end
        end
        
      end
      
      private
      
      def get_user_data(uid, params={})
        server = params[:server] || API
        uri = URI::encode("#{server}/user/#{uid}")
        warn "Request: »#{uri}«"
        Nokogiri::XML(open(uri))
      end
      
      def create_trackdir(uid, dir)
        return dir.sub(/:uid\b/, uid.to_s)
      end
    
    end
      
  end

end
