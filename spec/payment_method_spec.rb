require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'pp'

describe RSpreedlyCore::PaymentMethod do

  describe ".validate" do
    it "requires a token" do
      expect { RSpreedlyCore::PaymentMethod.validate() }.to raise_error(ArgumentError)
    end

    context "attributes" do
      before do
        stub_http_with_fixture('valid_payment_method.xml')
      end

      subject { RSpreedlyCore::PaymentMethod.validate("123") }

      it { should respond_to(*RSpreedlyCore::PaymentMethod.api_attributes) }
    end

    context "with a valid token" do
      before do
        stub_http_with_fixture('valid_payment_method.xml')
      end

      subject { RSpreedlyCore::PaymentMethod.validate('123') }

      context "Api attributes" do
        RSpreedlyCore::PaymentMethod.api_attributes.each do |attribute|
          it "#{attribute} is populated" do
            subject.send(attribute).should_not be nil
          end
        end
      end
    end

    context "Error handling" do
      it "records an invalid year when year is expired" do
        stub_http_with_fixture('invalid_year.xml')
        payment_method = RSpreedlyCore::PaymentMethod.validate('fake_invalid_year_token')
        errors = [{'year' => {'key' => 'errors.invalid', 'message' => 'Year is invalid'}},
          {'year' => {'key' => 'errors.expired', 'message' => 'Year is expired'}}]
        errors.each do |error_hash|
          payment_method.errors.should include error_hash
        end
      end

      it "records an invalid number when card numner is invalid" do
        stub_http_with_fixture('invalid_number.xml')
        payment_method = RSpreedlyCore::PaymentMethod.validate('fake_invalid_number_token')
        error = {'number'=> {'key' => 'errors.invalid', 'message' => 'Number is invalid'}}
        payment_method.errors.should include error
      end
    end

    context "with an invalid token" do
      it "returns an invalid token error" do
        stub_http_with_code(404)
        expect { RSpreedlyCore::PaymentMethod.validate("123") }.to raise_error(RSpreedlyCore::TokenNotFound)
      end
    end
  end

  describe "#retain" do
    it "creates a transaction of type 'retain'" do
      stub_http_with_fixture('valid_payment_method.xml')
      payment_method = RSpreedlyCore::PaymentMethod.validate("123")
      RSpreedlyCore::Transaction.expects(:retain).with(payment_method.token)
      payment_method.retain
    end
  end

  describe ".retain" do
    it "creates a transaction of type 'retain' for a given token" do
      stub_http_with_fixture('valid_payment_method.xml')
      payment_method = RSpreedlyCore::PaymentMethod.validate("123")
      RSpreedlyCore::Transaction.expects(:retain).with(payment_method.token)
      RSpreedlyCore::PaymentMethod.retain(payment_method.token)
    end
  end

  describe "#attributes" do
    it "returns a hash of attributes" do
      stub_http_with_fixture('valid_payment_method.xml')
      payment_method = RSpreedlyCore::PaymentMethod.new({:token => 'bar'})
      payment_method.attributes['token'].should == 'bar'
    end
  end
end
