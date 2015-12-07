module Maileon

  class Railtie < Rails::Railtie
    # initialize action_mailer with extra delivery_method before configs are applied to it
    # (see https://github.com/rails/rails/blob/master/actionmailer/lib/action_mailer/railtie.rb)
    # should work with generic rails 3/4 app
    initializer "maileon.action_mailer_extend", :before => "action_mailer.set_configs" do
      # require apapter code
      require 'maileon/mail_integration/delivery_methods/maileon_transaction'
      # add adapter class as delivery adapter to action_mailer
      ActionMailer::Base.add_delivery_method :maileon_transaction, Mail::MaileonTransactionDelivery, {}
    end
  end

end

