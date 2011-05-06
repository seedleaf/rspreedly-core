require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Api Requests" do
  context "requesting a valid payment method" do

    before :all do
      token = TestPaymentMethod.new.get_token
      @payment_method = RSpreedlyCore::PaymentMethod.new(token)
    end

    RSpreedlyCore::PaymentMethod::API_ATTRIBUTES.each do |attribute|
      it "#{attribute} is populated" do
        @payment_method.send(attribute).should_not be nil
      end
    end
  end
end
