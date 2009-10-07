module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Braintree
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          def initialize(order, account, options = {})
            super

            if ActiveMerchant::Billing::Base.integration_mode == :test || options[:test]
              self.account = "776320"
              self.api_key = "UVgCejU48ANga4mKF77WFXfm2yUve76W"
            end

            add_field('time', current_time)
            add_field('customer_vault_id', customer_id) unless customer_id.blank?
          end

          mapping :order, 'orderid'
          mapping :account, 'key_id'
          mapping :amount, 'amount'
          
          mapping :transaction_type, 'type'
 
          mapping :customer_id, 'customer_vault_id'
          mapping :storage_operation, 'customer_vault'
                    
          mapping :return_url, 'redirect'
          mapping :ip_address, 'ipaddress'
          
          mapping :order_description, 'orderdescription'
          mapping :payment_descriptor, 'descriptor'
          mapping :payment_descriptor_phone, 'descriptor_phone'
          
          mapping :customer, :first_name => 'firstname', :last_name => 'lastname',
                  :email => 'email', :phone => 'phone'
                  
          mapping :send_receipt, 'customer_receipt'
                  
          mapping :billing_address, :city     => 'city',
                                    :address1 => 'address1',
                                    :address2 => 'address2',
                                    :state    => 'state',
                                    :zip      => 'zip',
                                    :country  => 'country'
          
          mapping :shipping_address, :first_name => 'shipping_firstname',
                                     :last_name  => 'shipping_lastname',
                                     :city       => 'shipping_city',
                                     :address1   => 'shipping_address1',
                                     :address2   => 'shipping_address2',
                                     :state      => 'shipping_state',
                                     :zip        => 'shipping_zip',
                                     :country    => 'shipping_country'
          
          def form_fields
            ## Generating the hash requires fields that may not be set until 
            ## after the form is rendered (ie, they might get set by the controller),
            ## so we add it to the form here, because form_fields is called in
            ## ActionViewHelper only after payment_service_for yields.
            @fields.merge('hash' => generate_md5hash)
          end
          
          def current_time
            Time.now.utc.strftime("%Y%m%d%H%M%S")
          end
          
          def generate_md5string
            ## Format: orderid|amount|customer_vault_id|time|key
            ## # We need the '|' even if there's no orderid, in that case set
            ## this to "" to keep it from getting gobbled by the compact()
            orderid = @fields['orderid'] || ''
            amount = @fields['amount']
            customer_vault_id = @fields['customer_vault_id'] # Could be nil, which is fine
            time = @fields['time']
            key = self.api_key
            [orderid, amount, customer_vault_id, time, key].compact.join('|')
          end
          
          def generate_md5hash
            Digest::MD5.hexdigest(generate_md5string)
          end
          
        end
      end
    end
  end
end
