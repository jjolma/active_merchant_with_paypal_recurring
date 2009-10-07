require 'active_merchant/billing/integrations/braintree/helper.rb'
require 'active_merchant/billing/integrations/braintree/return.rb'
 
module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Braintree
        mattr_accessor :service_url
        self.service_url = 'https://secure.braintreepaymentgateway.com/api/transact.php'
        
        def self.return(query_string)
          Return.new(query_string)
        end
      end
    end
  end
end