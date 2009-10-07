require 'test_helper'

class PaypalModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def test_return_method
    assert_instance_of Braintree::Return, Braintree.return('name=cody')
  end
end 
