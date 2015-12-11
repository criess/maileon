module Maileon
  class API < Api::Base

    # load methods for URI: transation/*
    include Maileon::Api::TransactionMethods
    include Maileon::Api::MailingMethods
    include Maileon::Api::ContactMethods

    def ping
      session.get(:path => "#{@path}/ping", :headers => get_headers)
    end

    private
    def get_headers(type='json')
      {
        "Content-Type"  => "application/vnd.maileon.api+#{type}; charset=utf-8",
        "Authorization" => "Basic #{@apikey}"
      }
    end

    def is_valid_email(email)
      !/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/.match(email).nil?
    end

  end
end

