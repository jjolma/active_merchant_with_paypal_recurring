require 'test_helper'

class BraintreeReturnTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def test_invalid_request
    r = Braintree::Return.new(forged_request, :api_key => 'UVgCejU48ANga4mKF77WFXfm2yUve76W')
    assert !r.valid?
  end
  
  def test_successful_purchase
    r = Braintree::Return.new(successful_purchase, :api_key => 'UVgCejU48ANga4mKF77WFXfm2yUve76W')
    assert r.valid?
    assert r.success?
  end
  
  def test_failed_purchase
    r = Braintree::Return.new(failed_purchase, :api_key => 'UVgCejU48ANga4mKF77WFXfm2yUve76W')
    assert r.valid?
    assert !r.success?
  end
  
  def test_erroneous_purchase
    r = Braintree::Return.new(erroneous_purchase, :api_key => 'UVgCejU48ANga4mKF77WFXfm2yUve76W')
    assert r.valid?
    assert !r.success?
  end
  
  def test_attribute_mappings
    r = Braintree::Return.new(successful_purchase, :api_key => 'UVgCejU48ANga4mKF77WFXfm2yUve76W')
    assert_equal 'order-1', r.order_id
    assert_equal '123456', r.authorization
    assert_equal 'Successful purchase', r.message
    assert_equal 'M', r.cvv_result
    assert_equal 'Y', r.avs_result
    assert_equal 'customer-1', r.customer_id
    assert_equal 'transaction-1', r.transaction_id
  end
  
  private
  
  def forged_request
    'orderid=order-1&amount=25.00&response=1&transactionid=transaction-1&avsresponse=Y&cvvresponse=M&customer_vault_id=customer-1&time=20090717181533&hash=ee10f05e1bd59f4d0094b0be54c87e3q&responsetext=Successful+purchase'
  end
  
  def successful_purchase
    'orderid=order-1&amount=25.00&response=1&transactionid=transaction-1&avsresponse=Y&cvvresponse=M&customer_vault_id=customer-1&time=20090717181533&hash=ee10f05e1bd59f4d0094b0be54c87e3b&responsetext=Successful+purchase&authcode=123456'
  end
  
  def failed_purchase
    'orderid=order-1&amount=25.00&response=2&transactionid=transaction-1&avsresponse=Y&cvvresponse=M&customer_vault_id=customer-1&time=20090717181533&hash=6e6e4834d4202442d9006e44f9e181d2&responsetext=Insufficient funds'
  end
  
  def erroneous_purchase
    'orderid=order-1&amount=25.00&response=3&transactionid=transaction-1&avsresponse=Y&cvvresponse=M&customer_vault_id=customer-1&time=20090717181533&hash=f5dbe66043f150c2c41dc77d3c62f96d'
  end
end