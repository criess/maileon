module Maileon
  module Api
    module TransactionMethods
      def get_all_transaction_types(all = true, load_deep = false)
        url = "transactions/types"
        # TODO Paging support
        response = session.get(
          :path => "#{@path}#{url}?page_index=1",
          :headers => get_headers
        )

        if response.status == 200
          ret_hash = Hash.from_xml response.body
        end

        if load_deep
          # TODO implement deep load
        else
          ret_hash["transaction_types"]["transaction_type"]
        end
      end

      def get_transaction_type(type_id)
        url = "transactions/types/#{type_id}"
        response = session.get(
          :path => "#{@path}#{url}",
          :headers => get_headers
        )
        if response.status == 200
          ret_hash = Hash.from_xml response.body
        end
      end

      def create_transaction_type(name, variables = {})
        url = "transactions/types"
        body = {
          "name" => name,
          "content" => variables
        }

        response = session.post(
          :path => "#{@path}#{url}",
          :headers => get_headers.merge({ "Content-Type" => "application/json" }),
          :body => body.to_json
        )
        if response.status == 200
          ret_hash = Hash.from_xml response.body
        end
      end

      def create_transaction(id_of_transaction, params)

        raise "id_of_transaction must be integer" unless (id_of_transaction.is_a? Fixnum)
        url = "transactions"
        body = [
          {
            "type" => id_of_transaction,
            "import" => params["import"] || {},
            "content" => begin params.except("import").except("attachments") rescue {} end || {},
          }.merge(
            params["attachments"].is_a?(Array) ? {"attachments" => params["attachments"]} : {}
          )
        ]

        response = session.post(
          :path => "#{@path}#{url}",
          :headers => get_headers.merge({ "Content-Type" => "application/json" }),
          :body => body.to_json
        )
        if response.status == 200
          ret_hash = JSON.parse(response.body)
        end
      end

      def delete_transaction_type(type_id)
        raise "id_of_transaction must be integer" unless (type_id.is_a? Fixnum)
        url = "transactions/types/#{type_id}"
        response = session.delete(
          :path => "#{@path}#{url}",
          :headers => get_headers(:xml)
        )
        if response.status == 204
          true
        else
          false
        end
      end
    end
  end
end

