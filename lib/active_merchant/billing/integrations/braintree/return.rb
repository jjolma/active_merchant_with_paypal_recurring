# -*- coding: utf-8 -*-
module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Braintree
        class Return < ActiveMerchant::Billing::Integrations::Return
          # Parses and authenticates the redirect query_string from a Braintree
          # transaction. This class is intended to be instantiated by the controller 
          # that handles the url you pass to Braintree when making a "transparent redirect"
          # submission. It requires that you pass in your api_key before you authenticate
          # the parameters.
          
          # For example:
          # class SignupController < ApplicationController
          #   include ActiveMerchant::Billing::Integrations
          
          #   def redirect_url
          #     response = Braintree::Return.new(request.query_string, :api_key => @api_key)
          #     if response.success? && response.valid?
          #       ## Process the order
          #     end
          #   end
          # end

          ::TRANSACTION_RESPONSE_CODES = {
            '100' => 'Transaction was approved',
            '200' => 'Transaction was declined by Processor',
            '201' => 'Do Not Honor',
            '202' => 'Insufficient Funds',
            '203' => 'Over Limit',
            '204' => 'Transaction not allowed',
            '220' => 'Incorrect Payment Data',
            '221' => 'No such card issuer',
            '222' => 'No card number on file with Issuer',
            '223' => 'Expired card',
            '224' => 'Invalid expiration date',
            '225' => 'Invalid card security code',
            '240' => 'Call Issuer for further information',
            '250' => 'Pick up card',
            '251' => 'Lost card',
            '252' => 'Stolen card',
            '253' => 'Fraudulent card',
            '260' => 'Declined with further instructions available (see response text)',
            '261' => 'Declined – Stop all recurring payments',
            '262' => 'Declined – Stop this recurring program',
            '263' => 'Declined – Updated cardholder data available',
            '264' => 'Declined – Retry in a few days',
            '300' => 'Transaction was rejected by gateway',
            '400' => 'Transaction error returned by processor',
            '410' => 'Invalid merchant configuration',
            '411' => 'Merchant account is inactive',
            '420' => 'Communication error',
            '421' => 'Communication error with issuer',
            '430' => 'Duplicate transaction at processor',
            '440' => 'Processor format error',
            '441' => 'Invalid transaction information',
            '460' => 'Processor feature not available',
            '461' => 'Unsupported card type' }

          ::AVS_RESPONSE_CODES = {
            'X' => 'Exact match, 9-character ZIP',
            'Y' => 'Exact match, 5-character numeric ZIP',
            'D' => '“',
            'M' => '“',
            'A' => 'Address match only',
            'B' => '“',
            'W' => '9-character numeric ZIP match only',
            'Z' => '5-character ZIP match only',
            'P' => '“',
            'L' => '“',
            'N' => 'No address or ZIP match',
            'C' => '“',
            'U' => 'Address unavailable',
            'G' => 'Non-U.S. Issuer, does not participate',
            'I' => '“',
            'R' => 'Issuer system unavailable',
            'E' => 'Not a mail/phone order',
            'S' => 'Service not supported',
            '0' => 'AVS Not Available',
            'O' => '“',
            'B' => '“' }

          ::CVV_RESPONSE_CODES = {
            'M' => 'CVV2/CVC2 Match',
            'N' => 'CVV2/CVC2 No Match',
            'P' => 'Not Processed',
            'S' => 'Merchant has indicated that CVV2/CVC2 is not present on card',
            'U' => 'Issue is not certified and/or has not provided Visa encryption keys' }

          attr_reader :api_key
          attr_reader :order_id, :authorization, :avs_result, :cvv_result, :customer_id, :transaction_id

          def initialize(query_string, options = {})
            super(query_string)
            
            options.assert_valid_keys(:api_key)
            @api_key = options[:api_key]
            
            # The digest that proves authenticity.
            @response_hash = params["hash"]
            
            # Params that should be incorporated into the hash and protected from forgery.
            @order_id = params["orderid"]
            @amount = params["amount"]
            @response = params["response"]
            @transaction_id = params["transactionid"]
            @avs_result = params["avsresponse"]
            @cvv_result = params["cvvresponse"]
            @customer_id = params["customer_vault_id"]
            @response_time = params["time"]
            
            # Other params.
            @message = params["responsetext"]
            @authorization = params["authcode"]
          end
          
          def success?
            @response == "1"
          end
          
          def message
            @message
          end
          
          def valid?
            generate_md5hash == @response_hash
          end
          
          def parse_time
            ## Returns a ruby Time object for time string returned from Braintree
            Time.utc(*@response_time.scan(/([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})/)[0])
          end

          def generate_md5string
            customer_id = (@customer_id == "") ? nil : @customer_id

            [@order_id, @amount, @response, @transaction_id, @avs_result, @cvv_result,
             customer_id, @response_time, @api_key].compact.join("|")
          end

          def generate_md5hash
            Digest::MD5.hexdigest(generate_md5string)
          end
        end
      end
    end
  end
end
