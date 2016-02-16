module Maileon
  module Api
    module ReportMethods
      # GET https://api.maileon.com/1.0/reports/opens/unique
      def get_unique_opens_by_email email
        get_unique_opens({ :emails => email })
      end

      # GET https://api.maileon.com/1.0/reports/clicks/unique
      def get_unique_clicks_by_email email
        get_unique_clicks({ :emails => email })
      end

      # GET https://api.maileon.com/1.0/reports/bounces/unique
      def get_unique_bounces_by_email email
          get_unique_bounces({ :emails => email })
      end

      # GET https://api.maileon.com/1.0/reports/recipients
      def get_recipients_by_email email
        url = "reports/recipients?emails=#{CGI.escape email}"
        response = session.get(
          :path => "#{@path}#{url}",
          :headers => get_headers.merge({ "Content-Type" => "application/vnd.maileon.api+xml" })
        )
        Hash.from_xml response.body
      end

      def get_unique_bounces params = {}
        url = "reports/bounces/unique?#{params.to_query}"
        response = session.get(
          :path => "#{@path}#{url}",
          :headers => get_headers.merge({ "Content-Type" => "application/vnd.maileon.api+xml" })
        )
        Hash.from_xml response.body
      end

      def get_unique_clicks params = {}
        url = "reports/clicks/unique?#{params.to_query}"
        response = session.get(
          :path => "#{@path}#{url}",
          :headers => get_headers.merge({ "Content-Type" => "application/vnd.maileon.api+xml" })
        )
        Hash.from_xml response.body
      end

      def get_unique_opens params = {}
        url = "reports/opens/unique?#{params.to_query}"
        response = session.get(
          :path => "#{@path}#{url}",
          :headers => get_headers.merge({ "Content-Type" => "application/vnd.maileon.api+xml" })
        )
        Hash.from_xml response.body
      end

      # GET https://api.maileon.com/1.0/reports/recipients
      def get_recipients params = {}
        url = "reports/recipients?#{params.to_query}"
        response = session.get(
          :path => "#{@path}#{url}",
          :headers => get_headers.merge({ "Content-Type" => "application/vnd.maileon.api+xml" })
        )
        Hash.from_xml response.body
      end

      # GET https://api.maileon.com/1.0/reports/blocks
      def get_blocks params = {}
        url = "reports/blocks?#{params.to_query}"
        response = session.get(
          :path => "#{@path}#{url}",
          :headers => get_headers.merge({ "Content-Type" => "application/vnd.maileon.api+xml" })
        )
        Hash.from_xml response.body
      end
    end
  end
end

