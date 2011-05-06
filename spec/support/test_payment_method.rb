class TestPaymentMethod
  include HTTParty
  format :xml
  base_uri "https://spreedlycore.com"


  API_ATTRIBUTES = [:token, :number, :verification_value, :month, :year,
    :first_name, :last_name, :card_type, :address1, :address2, :city, :state,
    :zip, :country, :phone_number, :email ]

  DEFAULT_OPTIONS = {
    'redirect_url' => 'http://localhost',
    'api_login' => RSpreedlyCore::Config[:api_login]
  }

  DEFAULT_CREDIT_CARD_OPTIONS = {
    'first_name' => 'Joe',
    'last_name' =>  'Member',
    'number' => '4111111111111111',
    'verification_value' => '123',
    'card_type' => 'visa',
    'month' => Date.today.month,
    'year' => Date.today.year,
    'address1' => '123 test lane',
    'address2' => 'Apartment Z',
    'city' => 'Floyd',
    'state' => 'VA',
    'country' => 'USA',
    'zip' => '90210',
    'phone_number' => '555-555-5555',
    'email' => 'joe@member.com'
  }

  attr_accessor *API_ATTRIBUTES
  attr_reader :attributes, :response

  def initialize(credit_card_attributes={})
    credit_card_attributes = DEFAULT_CREDIT_CARD_OPTIONS.merge(credit_card_attributes)
    @attributes = DEFAULT_OPTIONS.merge({'credit_card' => credit_card_attributes})
  end

  def default_options
    DEFAULT_OPTIONS.merge(DEFAULT_CREDIT_CARD_OPTIONS)
  end

  def post_payment_method_form
    @response = self.class.post("/v1/payment_methods",
                                :body => self.attributes,
                                :follow_redirects => false)
  end

  def get_token
    response = post_payment_method_form
    response.body.match(/token=(.*)\"/)[1]
  end
end
