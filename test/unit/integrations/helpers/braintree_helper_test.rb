require 'test_helper'

class BraintreeHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def setup
    @helper = Braintree::Helper.new('order-500', '776320', :amount => '5.00', :currency => 'USD', :api_key => 'UVgCejU48ANga4mKF77WFXfm2yUve76W')
    
    @helper.stubs(:current_time).returns(Time.now.utc.strftime("%Y%m%d%H%M%S")) # Ensure consistent hashing
    
    @helper.return_url = 'https://mysite.com/payment_notification'
  end
  
  def teardown
    ActiveMerchant::Billing::Base.integration_mode = :test
  end
  
  def test_basic_helper_fields
    assert_field 'key_id', '776320'
    assert_field 'orderid', 'order-500'
    assert_field 'amount', '5.00'
    assert_field 'time', @helper.current_time
    assert_field 'hash', @helper.generate_md5hash
    assert_field 'redirect', 'https://mysite.com/payment_notification'
  end
  
  def test_api_key_not_exposed
    assert_equal 6, @helper.form_fields.length
  end
  
  def test_generate_hash_string
    assert_equal "order-500|5.00|#{@helper.current_time}|UVgCejU48ANga4mKF77WFXfm2yUve76W", @helper.generate_md5string
  end
  
  def test_generate_hash_string_without_order_includes_placeholder
    @helper = Braintree::Helper.new(nil, '776320', :amount => '5.00', :currency => 'USD', :api_key => 'UVgCejU48ANga4mKF77WFXfm2yUve76W')
    assert_equal "|5.00|#{@helper.current_time}|UVgCejU48ANga4mKF77WFXfm2yUve76W", @helper.generate_md5string
  end
  
  def test_generate_hash_string_includes_optional_customer_vault_id
    @helper.customer_id = 'customer-1'
    assert_equal "order-500|5.00|customer-1|#{@helper.current_time}|UVgCejU48ANga4mKF77WFXfm2yUve76W", @helper.generate_md5string
  end
  
  def test_generate_md5_hash
    assert_equal @helper.generate_md5hash, Digest::MD5.hexdigest(@helper.generate_md5string)
  end
  
  def test_description_fields
    @helper.order_description = 'An armada of rubber ducks'
    @helper.payment_descriptor = 'Ducks R Us'
    @helper.payment_descriptor_phone = '(555)555-5555'
    
    assert_field 'orderdescription', 'An armada of rubber ducks'
    assert_field 'descriptor', 'Ducks R Us'
    assert_field 'descriptor_phone', '(555)555-5555'
  end
  
  def test_customer_fields
    @helper.customer :first_name => 'Cody', :last_name => 'Fauser', :email => 'cody@example.com', :phone => '(555)555-5555'
    assert_field 'firstname', 'Cody'
    assert_field 'lastname', 'Fauser'
    assert_field 'email', 'cody@example.com'
    assert_field 'phone', '(555)555-5555'
  end
  
  def test_customer_vault_fields
    @helper.customer_id = 'customer-1'
    @helper.storage_operation = 'add_customer'
    assert_field 'customer_vault_id', 'customer-1'
    assert_field 'customer_vault', 'add_customer'
  end
  
  def test_receipts
    @helper.send_receipt = true
    assert_field 'customer_receipt', 'true'
  end
  
  def test_billing_address
    @helper.billing_address :address1 => '1 My Street',
                            :address2 => 'Apt. 1',
                            :city => 'Leeds',
                            :state => 'Yorkshire',
                            :zip => 'LS2 7EE',
                            :country  => 'CA'
   
    assert_field 'address1', '1 My Street'
    assert_field 'address2', 'Apt. 1'
    assert_field 'city', 'Leeds'
    assert_field 'state', 'Yorkshire'
    assert_field 'zip', 'LS2 7EE'
    assert_field 'country', 'CA'
  end
  
  def test_shipping_address
    @helper.shipping_address :first_name => 'Jon',
                             :last_name => 'Shea',
                             :address1 => '1 My Street',
                             :address2 => 'Apt. 1',
                             :city => 'London',
                             :state => 'Whales',
                             :zip => 'LS2 7E1',
                             :country  => 'UK'
    
    assert_field 'shipping_firstname', 'Jon'
    assert_field 'shipping_lastname', 'Shea'
    assert_field 'shipping_city', 'London'
    assert_field 'shipping_address1', '1 My Street'
    assert_field 'shipping_address2', 'Apt. 1'
    assert_field 'shipping_state', 'Whales'
    assert_field 'shipping_zip', 'LS2 7E1'
    assert_field 'shipping_country', 'UK'
  end
  
  def test_force_test_mode
    ActiveMerchant::Billing::Base.integration_mode = :production
    @helper = Braintree::Helper.new('order-500', 'my-key-id', :amount => '5.00', :currency => 'USD', :api_key => 'shared-secret-key', :test => true)
    assert_field 'key_id', '776320'
  end
  
  def test_production_mode
    ActiveMerchant::Billing::Base.integration_mode = :production
    @helper = Braintree::Helper.new('order-500', 'my-key-id', :amount => '5.00', :currency => 'USD', :api_key => 'shared-secret-key')
    assert_field 'key_id', 'my-key-id'
  end
end
