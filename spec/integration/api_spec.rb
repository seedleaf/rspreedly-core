require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Api Requests" do
  context "requesting a valid payment method" do
    before :all do
      @token = TestPaymentMethod.new.get_token
      @payment_method = RSpreedlyCore::PaymentMethod.validate(@token)
    end

    RSpreedlyCore::PaymentMethod.api_attributes.each do |attribute|
      it "#{attribute} is populated" do
        @payment_method.send(attribute).should_not be nil
      end
    end

    context "retaining a credit card" do
      context 'when successful' do
        it 'returns a successful transaction' do
          transaction = @payment_method.retain
          transaction.should be_success
        end
      end
    end
    
    context "redacting a credit card" do
      context 'when successful' do
        it 'returns a successful transaction' do
          transaction = @payment_method.redact
          transaction.should be_success
        end
      end
      
    end

    context "making a purchase" do
      it 'returns a successful purchase transaction with valid card and amount' do
        transaction = @payment_method.purchase(100)
        transaction.transaction_type.should == "purchase"
        transaction.should be_success
        transaction.response["message"].should == "Successful purchase!"
      end
      
      it 'fails with negative amounts' do
        expect { @payment_method.purchase(-100) }.
          to raise_error(RSpreedlyCore::UnprocessableEntity, "Amount must be greater than 0")
      end
    end
    
    context "making an authorization" do
      it 'returns a successful authorization transaction with valid card and amount' do
        transaction = @payment_method.authorize(100)
        transaction.transaction_type.should == "authorization"
        transaction.should be_success
        transaction.response["message"].should == "Successful authorize!"
      end
      
      it 'fails with negative amounts' do
        expect { @payment_method.authorize(-100) }.
          to raise_error(RSpreedlyCore::UnprocessableEntity, "Amount must be greater than 0")
      end
    end
    
    context "making a capture" do
      
      let (:auth_token) {@payment_method.authorize(100).token}
      
      it 'returns a successful capture transaction with a good card and full capture' do
        transaction = @payment_method.capture(auth_token)
        transaction.transaction_type.should == "capture"
        transaction.should be_success
        transaction.response["message"].should == "Successful capture!"
      end
      
      it 'returns a successful capture transaction with a good card and partial capture' do
        transaction = @payment_method.capture(auth_token, 150)
        transaction.transaction_type.should == "capture"
        transaction.should be_success
        transaction.response["message"].should == "Successful capture!"
        transaction.amount.should == 50
      end
      
      it 'fails with amounts greater than authorization' do
        expect { @payment_method.capture(auth_token, 105) }.
          to raise_error(RSpreedlyCore::UnprocessableEntity, "Amount must be greater than 0")
      end
    end
  end
  

  context "requesting a payment method without valid credentials" do
    it "raises an invalid credentials error" do
      RSpreedlyCore::Config[:api_secret] = nil
      expect { RSpreedlyCore::PaymentMethod.validate('xyz') }.to raise_error(RSpreedlyCore::InvalidCredentials)
    end
  end
end
