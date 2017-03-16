require 'mail/check_delivery_params'
require 'active_support/core_ext'

module Mail

  # Sending email from maileon via action_mailer's deliver-method
  # Integrates with action_mailer via railtie for rails 3/4 (see lib/maileon/railtie.rb)
  # configuration could be done on application initializers
  #   config.action_mailer.delivery_method              = :maileon_transaction
  #   config.action_mailer.maileon_transaction_settings = {
  #     :api_key         => "xxxxxx-yyy-xxx-yyyyyy",
  #     :update_contacts => true|false
  #   }
  class MaileonTransactionDelivery
    include Mail::CheckDeliveryParams

    HEADER_TYPE_KEY = :"X-Maileon-TransactionType"
    HEADER_VARS_KEY = :"X-Maileon-Variables"
    HEADER_ATTACHMENTS_KEY = :"X-Maileon-Attachments"

    attr_accessor :settings
    attr_reader   :api

    @@has_notifications_installed = false

    # emtpy initializer for now
    def initialize settings
      # init settings with defaults
      @settings ||= {
        :update_contacts => false
      }
      @settings.merge!(settings)

      # api object
      @api = Maileon::API.new(settings[:api_key])

      @api.session.data[:instrumentor_name] = "maileon_api"
      @api.session.data[:instrumentor]      = ActiveSupport::Notifications

      install_notifications_for_class!
    end

    def install_notifications_for_class!
      if !@@has_notifications_installed
        ActiveSupport::Notifications.subscribe /^maileon_api/ do |name, started, finished, unique_id, payload|
          http_method_pretty = "#{payload[:method].to_s.upcase}"
          timings_pretty     = "#{( (finished - started) * 1000).floor}"
          action_path        = ""
          logger.info  "  maileon_api (#{http_method_pretty}) (}) #{timings_pretty} ms" unless http_method_pretty == ""
        end
        @@has_notifications_installed = true
      end

      # self-chaining enabled
      self
    end

    def deliver!(mail)
      # implement maileon send
      check_delivery_params(mail)

      # query api for type
      transaction_type = check_maileon_transaction_params(mail)

      # query api for variables
      # generate variable mapping
      variables = check_maileon_variables(transaction_type, mail)

      # prepare attachments to be committed within transaction
      attachments = check_maileon_attachments(mail)
      # add attachment data to variables
      if attachments.size > 0
        variables["attachments"] = attachments
      end

      # send type api with params
      transaction = api.create_transaction(
        transaction_type["id"].to_i,
        # deep_merge from active_support
        variables.deep_merge(
          {
            "import" => {
              "contact" => {
                "email" => mail["to"].value,
                # TODO resolve hardcoded user permission here for dynamic version
                "permission" => 5
              }
            }
          }
        )
      )

      logger.warn "Maileon Transaction Response :: #{transaction}"

      # update maileon contact if transaction was success
      if settings[:update_contacts] &&
        transaction.try(:[],"reports").try(:size) == 1 &&
        variables.try(:[], "import").try(:[], "contact")
        contact_variables = variables["import"]["contact"].clone.tap do |hash|
          hash["email"] = mail["to"].value
        end
        api.update_contact_by_email(contact_variables["email"], contact_variables)
      end

      # mail
      mail
    end

    private
    def check_maileon_transaction_params mail
      check_api_key
      check_transaction_type mail
    end

    def check_api_key
      # TODO check api if key works for create and read
    end

    def check_transaction_type mail
      avail_transactions = api.get_all_transaction_types

      finder = lambda do |entry|
        entry["name"] == "#{mail[HEADER_TYPE_KEY].field}"
      end

      raise (runtime_error "unable to find transaction") unless avail_transactions.find(&finder)
      avail_transactions.find(&finder)
    end

    def check_maileon_variables(transaction_type, mail)
      begin
        variables = JSON.parse mail[HEADER_VARS_KEY].value
      rescue
        raise (runtime_error "unable to load/parse :maileon_variables for mail")
      end
      errors = transaction_type["attributes"]["attribute"].inject([]) do |errors, entry|
        errors << entry["name"] unless variables.keys.include?(entry["name"])
        errors
      end
      logger.debug "check_maileon_variables #{transaction_type["attributes"]["attribute"]}"
      raise (runtime_error "missing variable/s #{errors}") unless errors.empty?
      errors.empty? && variables
    end

    def check_maileon_attachments(mail)
      begin
        file_links = JSON.parse mail[HEADER_ATTACHMENTS_KEY].value
      rescue
        raise (runtime_error "unable to load/parse :maileon_attachments for mail")
      end

      attachments = Array.new

      # append hashes with
      # :data => file payload in base64
      # :mime =>
      # :name => name to display in email
      file_links.each do |name, file_to_load|
        absolute_path = File.join Rails.root, "#{file_to_load}"
        attachments << {
          :data => Base64.encode64(
            File.open(absolute_path, "rb").read
          ),
          :mime => "#{Mime::Type.lookup_by_extension( name.split(".").last ) || "application/octet-stream"}",
          :name => "#{name}"
        }
      end

      attachments
    end

    def runtime_error msg
       RuntimeError.new "maileon action_mailer integration :: #{msg}"
    end

    def logger
      ActionMailer::Base.logger
    end

  end
end

