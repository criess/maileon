module Maileon
  module Api
    module FieldBackupMethods
      # POST https://api.maileon.com/1.0/contacts/backup
      # type: indicates the type of the contact field. Supported values are:
      #       "standard", "custom" (custom contact fields) and "event" (contact
      #        event properties)
      def create_contact_field_backup_instruction type, field
        body = "<backup_instruction>
          <type>#{type}</type>
          <name>#{field}</name>
        </backup_instruction>"
        url = "contacts/backup"
        response = session.post(
          :path => "#{@path}#{url}",
          :headers => get_headers.merge({ "Content-Type" => "application/vnd.maileon.api+xml" }),
          :body => body
        )
        response
      end

      # GET https://api.maileon.com/1.0/contacts/backup
      def get_contact_field_backup_instruction
        url = "contacts/backup"
        response = session.get(
          :path => "#{@path}#{url}",
          :headers => get_headers.merge({ "Content-Type" => "application/vnd.maileon.api+xml" })
        )
        Hash.from_xml response.body
      end

      # DELETE https://api.maileon.com/1.0/contacts/backup/:id
      def delete_contact_field_backup_instruction b_id
        url = "contacts/backup/#{b_id}"
        response = session.delete(
          :path => "#{@path}#{url}",
          :headers => get_headers.merge({ "Content-Type" => "application/vnd.maileon.api+xml" })
        )
        response
      end

    end
  end
end

