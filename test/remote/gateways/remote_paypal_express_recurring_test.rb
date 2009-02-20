require File.dirname(__FILE__) + '/../../test_helper'

class PaypalExpressRecurringTest < Test::Unit::TestCase
  def setup
    Base.gateway_mode = :test
    @gateway = PaypalExpressRecurringGateway.new(fixtures(:paypal_certificate))
  end

  def test_setup_agreement
	response = @gateway.setup_agreement(:description => "Subscription $25 per month", 
                                        :cancel_return_url => "https://example.com/payment/cancel", 
                                        :return_url => "https://mysite.com/payment/complete" )
    assert response.test?
    assert !response.token.blank?
    assert_not_nil @gateway.redirect_url_for(response.token)
  end

end 
