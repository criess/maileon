module Maileon
  module Api
    module ContactMethods
      def update_contact_by_email email, data = {}
        url = "contacts/email/#{CGI.escape email}?sync_mode=1"
        data["email"] = email
        response = session.post(
          :path => "#{@path}#{url}",
          :headers => get_headers.merge({ "Content-Type" => "application/vnd.maileon.api+json" }),
          :body => data.to_json
        )
        if response.status == 201
          true
        end
      end

      #
      # legacy methods from original fork
      # * create_contact
      # * delete_contact
      #
      def create_contact(params, body={})
        raise ArgumentError.new("No parameters.") if params.empty?
        raise ArgumentError.new("Emgetail is mandatory.") if params[:email].nil?
        raise Maileon::Errors::ValidationError.new("Invalid email format.") unless is_valid_email(params[:email])
        email = URI::escape(params[:email])
        permission = params[:permission] ||= 1
        sync_mode = params[:sync_mode] ||= 2
        src = params[:src]
        subscription_page = params[:subscription_page]
        doi = params[:doi] ||= true
        doiplus = params[:doiplus] ||= true
        doimailing = params[:doimailing]
        url = "contacts/#{email}?permission=#{permission}&sync_mode=#{sync_mode}&doi=#{doi}&doiplus=#{doiplus}"
        url << "&doimailing=#{doimailing}" unless doimailing.nil?
        url << "&src=#{src}" unless src.nil?
        url << "&subscription_page=#{subscription_page}" unless subscription_page.nil?
        session.post(:path => "#{@path}#{url}", :headers => get_headers, :body => body.to_json)
      end

      def delete_contact(params)
        raise ArgumentError.new("No parameters.") if params.empty?
        raise ArgumentError.new("Email is mandatory.") if params[:email].nil?
        raise Maileon::Errors::ValidationError.new("Invalid email format.") unless is_valid_email(params[:email])
        email = URI::escape(params[:email])
        url = "contacts/#{email}"
        session.delete(:path => "#{@path}#{url}", :headers => get_headers('xml'))
      end

      # GET https://api.maileon.com/1.0/contacts/email/:value
      def get_contact_by_email email
        url = "contacts/email/#{CGI.escape email}"
        response = session.get(
          :path => "#{@path}#{url}",
          :headers => get_headers.merge({ "Content-Type" => "application/vnd.maileon.api+xml" }),
        )
        Hash.from_xml response.body
      end
    end
  end
end

