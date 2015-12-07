module Maileon
  module Api
    module MailingMethods

      MAILING_STATES = %w(draft failed queued checks blacklist preparing sending canceled paused done archiving archived released)

      # GET https://api.maileon.com/1.0/mailings/filter/types
      def get_mailings_with_type(type = :trigger, extra_information)
        url = "mailings/filter/types"
        response = session.get(
          :path => "#{@path}#{url}?page_index=1&types=#{type}",
          :headers => get_headers
        )
        if response.status == 200
          ret_hash = Hash.from_xml response.body
        end

        # query extra info
        if extra_information.is_a? Array
          ret_hash["mailings"]["mailing"].each do |mg|
            extra_information.each do |extra_index|
              mg.merge!( send(:"get_mailing_#{extra_index}", mg["id"]) || {} )
            end
          end
        elsif extra_information.is_a? String
          ret_hash["mailings"]["mailing"].each do |mg|
            mg.merge!( send(:"get_mailing_#{extra_information}", mg["id"]) || {} )
          end
        else
          ret_hash
        end
      end

      # GET https://api.maileon.com/1.0/mailings/:mailingid/dispatching
      def get_mailing_dispatching (m_id = 0)
        url = "mailings/#{m_id}/dispatching"
        response = session.get(
          :path => "#{@path}#{url}",
          :headers => get_headers
        )
        if response.status == 200
          ret_hash = Hash.from_xml response.body
        end
      end

      # GET https://api.maileon.com/1.0/mailings/:mailingid/name
      def get_mailing_name (m_id = 0)
        url = "mailings/#{m_id}/name"
        response = session.get(
          :path => "#{@path}#{url}",
          :headers => get_headers
        )
        if response.status == 200
          ret_hash = Hash.from_xml response.body
        end
      end

      # GET https://api.maileon.com/1.0/mailings/:mailingid/state
      def get_mailing_state (m_id = 0)
        url = "mailings/#{m_id}/state"
        response = session.get(
          :path => "#{@path}#{url}",
          :headers => get_headers
        )
        if response.status == 200
          ret_hash = Hash.from_xml response.body
        end
      end

    end
  end
end

