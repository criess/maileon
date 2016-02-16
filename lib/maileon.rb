require 'base64'
require 'excon'
require 'json'

require 'maileon/version'
require 'maileon/errors'
require 'maileon/api/base'
require 'maileon/api/contact_methods'
require 'maileon/api/transaction_methods'
require 'maileon/api/mailing_methods'
require 'maileon/api/report_methods'
require 'maileon/api/field_backup_methods'
require 'maileon/api'
require 'maileon/railtie' if (defined? Rails::Railtie) # only enable rails integration if available

