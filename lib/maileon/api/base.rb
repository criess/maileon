module Maileon
  module Api
   class Base

     attr_accessor :host, :path, :apikey, :debug, :session

     API_PROTOCOL = "https"
     API_HOST = "api.maileon.com"
     API_PATH = "/1.0/"

     def initialize(apikey=nil, debug=false)
        @host = "#{API_PROTOCOL}://#{API_HOST}"
        @path = "#{API_PATH}"

        unless apikey
          apikey = ENV['MAILEON_APIKEY']
        end

        raise 'You must provide Maileon API key' unless apikey

        self.apikey  = Base64.encode64(apikey).strip
        self.debug   = debug
        self.session = Excon.new @host, :debug => debug
      end

    end
  end
end

