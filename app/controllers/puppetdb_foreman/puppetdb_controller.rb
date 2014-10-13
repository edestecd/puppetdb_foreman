module PuppetdbForeman
  class PuppetdbController < ApplicationController

    def index
      begin
        uri = URI.parse(Setting[:puppetdb_dashboard_address])
        puppetdb_url, layout = case params[:puppetdb]
                               when 'd3.v2', 'charts' then ["#{uri.path}#{request.original_fullpath}", false]
                               when 'v3'              then [request.original_fullpath, false]
                               else                        ["#{uri.path}/index.html", true]
                               end
        result = Net::HTTP.get_response(uri.host, puppetdb_url, uri.port)
        render :text => result.body, :layout => layout
      rescue SocketError => error
        @proxy_error = "Problem connecting to host #{uri.host} on port #{uri.port}"
        render :action => :error, :layout => true
      rescue Errno::ECONNREFUSED => error
        @proxy_error = "#{uri.host} refused our conneciton"
        render :action => :error, :layout => true
      rescue EOFError => error
        @proxy_error = "Don't use ssl (https)"
        render :action => :error, :layout => true
      end
    end

    # Override from application controller to fix issue
    def api_request?
      request.format && (request.format.json? || request.format.yaml?)
    end

  end
end
