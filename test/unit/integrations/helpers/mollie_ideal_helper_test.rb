require 'test_helper'

class MollieIdealHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @required_options = {
      :account_name => "My shop",
      :amount => 500, 
      :currency => 'EUR', 
      :redirect_param => 'ideal_TESTNL99',
      :return_url => 'https://return.com',
      :metadata => { :my_reference => 'unicorn' }
    }

    @helper = MollieIdeal::Helper.new('order-500','1234567', @required_options)
  end
 
  def test_request_redirect_uri
    MollieIdeal.expects(:mollie_api_request).returns(CREATE_PAYMENT_RESPONSE_JSON)
    uri = @helper.request_redirect_uri
    assert_equal "https://www.mollie.nl/paymentscreen/ideal/testmode?transaction_id=20a5a25c2bce925b4fabefd0410927ca&bank_trxid=0148703115482464", uri.to_s
  end

  def test_credential_based_url
    MollieIdeal.expects(:mollie_api_request).returns(CREATE_PAYMENT_RESPONSE_JSON)
    uri = @helper.credential_based_url
    
    assert_equal "https://www.mollie.nl/paymentscreen/ideal/testmode", uri
    assert_equal "20a5a25c2bce925b4fabefd0410927ca", @helper.fields['transaction_id']
    assert_equal "0148703115482464", @helper.fields['bank_trxid']
  end

  def test_raises_without_required_options
    assert_raises(ArgumentError) { MollieIdeal::Helper.new('order-500','1234567', @required_options.merge(:redirect_param => nil)) }
    assert_raises(ArgumentError) { MollieIdeal::Helper.new('order-500','1234567', @required_options.merge(:return_url => nil)) }
    assert_raises(ArgumentError) { MollieIdeal::Helper.new('order-500','1234567', @required_options.merge(:account_name => nil)) }
  end

  CREATE_PAYMENT_RESPONSE_JSON = JSON.parse(<<-JSON)
    {
      "id":"tr_djsfilasX",
      "mode":"test",
      "createdDatetime":"2014-03-03T10:17:05.0Z",
      "status":"open",
      "amount":"500.00",
      "description":"My order description",
      "method":"ideal",
      "metadata":{
        "my_reference":"unicorn"
      },
      "details":null,
      "links":{
        "paymentUrl":"https://www.mollie.nl/paymentscreen/ideal/testmode?transaction_id=20a5a25c2bce925b4fabefd0410927ca&bank_trxid=0148703115482464",
        "redirectUrl":"https://example.com/return"
      }
    }
  JSON
end
