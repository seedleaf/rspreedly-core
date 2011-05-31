require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'pp'

describe RSpreedlyCore::Transaction do
  describe "#success?" do
    it "returns true when transaction succeeded" do
      transaction = RSpreedlyCore::Transaction.new(:succeeded => true)
      transaction.should be_success
    end
    it "returns false when transaction succeeded" do
      transaction = RSpreedlyCore::Transaction.new(:succeeded => false)
      transaction.should_not be_success
    end

  end

  describe ".payment_method_transaction" do
    context "when retaining" do
      before do
        stub_http_with_fixture('successful_retain.xml')
      end
      let(:transaction) { RSpreedlyCore::Transaction.payment_method_transaction('retain', 'xyz') }

      it "returns a successful transaction" do
        transaction.should be_instance_of RSpreedlyCore::Transaction
        transaction.should be_success
      end

      it "returns a transaction with 'RetainPaymentMethod' type" do
        transaction.transaction_type.should == 'RetainPaymentMethod'
      end

      it "returns a token for the transaction" do
        transaction.token.should_not be nil
      end

      it "makes a retain request" do
        token = "some_token"
        path = "/payment_methods/#{token}/retain.xml"
        request = mock('request', :response => {'transaction' => {}})
        RSpreedlyCore::Request.expects(:new).with(:put, path).returns(request)
        RSpreedlyCore::Transaction.payment_method_transaction('retain', token)
      end
    end
    
    context "when retaining" do
      before do
        stub_http_with_fixture('successful_redact.xml')
      end
      let(:transaction) { RSpreedlyCore::Transaction.payment_method_transaction('redact', 'xyz') }

      it "returns a successful transaction" do
        transaction.should be_instance_of RSpreedlyCore::Transaction
        transaction.should be_success
      end

      it "returns a transaction with 'RedactPaymentMethod' type" do
        transaction.transaction_type.should == 'RedactPaymentMethod'
      end

      it "returns a token for the transaction" do
        transaction.token.should_not be nil
      end

      it "makes a redact request" do
        token = "some_token"
        path = "/payment_methods/#{token}/redact.xml"
        request = mock('request', :response => {'transaction' => {}})
        RSpreedlyCore::Request.expects(:new).with(:put, path).returns(request)
        RSpreedlyCore::Transaction.payment_method_transaction('redact', token)
      end
    end
  end
  
  describe ".gateway_transaction" do
    context "when purchasing" do
      context "when successful" do
        before do
          stub_http_with_fixture('successful_purchase.xml')
        end
        let(:transaction) { RSpreedlyCore::Transaction.gateway_transaction('purchase', 100, 'xyz') }
        
        it "returns a successful transaction" do
           transaction.should be_instance_of RSpreedlyCore::Transaction
           transaction.should be_success
        end
        
        it "returns a transaction of purchase type" do
          transaction.transaction_type.should == 'purchase'
        end
        
        it "returns a detailed response hash" do
          keys = ["success","message","avs_code","avs_message","cvv_code","cvv_message",
                  "error_code","error_detail","created_at","updated_at"]
          transaction.response.keys.sort.should == keys.sort
        end
      end
        
      context "failures" do
        it "raise an unprocessable entity error when amount is negative" do
          stub_http_with_fixture('failed_negative_purchase.xml', 422)
          expect { RSpreedlyCore::Transaction.gateway_transaction('purchase', -100, 'xyz') }.
            to raise_error(RSpreedlyCore::UnprocessableEntity, "Amount must be greater than 0")
        end
        
        it "returns a failed transaction when card is not processable" do
          stub_http_with_fixture('failed_card_purchase.xml', 422)
          transaction = RSpreedlyCore::Transaction.gateway_transaction('purchase', 100, 'xyz')
          transaction.should_not be_success
          transaction.response["message"].should == "Unable to process the transaction."
        end
      end
    end
    
    context "when authorizing" do
      context "when successful" do
        before do
          stub_http_with_fixture('successful_authorize.xml')
        end
        let(:transaction) { RSpreedlyCore::Transaction.gateway_transaction('authorize', 100, 'xyz') }
        
        it "returns a successful transaction" do
           transaction.should be_instance_of RSpreedlyCore::Transaction
           transaction.should be_success
        end
        
        it "returns a transaction of authorize type" do
          transaction.transaction_type.should == 'authorization'
        end
        
        it "returns a detailed response hash" do
          keys = ["success","message","avs_code","avs_message","cvv_code","cvv_message",
                  "error_code","error_detail","created_at","updated_at"]
          transaction.response.keys.sort.should == keys.sort
        end
      end
        
      context "failures" do
        it "raise an unprocessable entity error when amount is negative" do
          stub_http_with_fixture('failed_negative_authorize.xml', 422)
          expect { RSpreedlyCore::Transaction.gateway_transaction('auuhtorize', -100, 'xyz') }.
            to raise_error(RSpreedlyCore::UnprocessableEntity, "Amount must be greater than 0")
        end
        
        it "returns a failed transaction when card is not processable" do
          stub_http_with_fixture('failed_card_authorize.xml', 422)
          transaction = RSpreedlyCore::Transaction.gateway_transaction('authorize', 100, 'xyz')
          transaction.should_not be_success
          transaction.response["message"].should == "Unable to process the transaction."
        end
      end
    end
    
    context "when capturing" do
      context "when successful full capture" do
        before do
          stub_http_with_fixture('successful_capture.xml')
        end
        let(:transaction) { RSpreedlyCore::Transaction.gateway_transaction('capture', nil, 'xyz') }
        
        it "returns a successful transaction" do
           transaction.should be_instance_of RSpreedlyCore::Transaction
           transaction.should be_success
        end
        
        it "returns a transaction of capture type" do
          transaction.transaction_type.should == 'capture'
        end
        
        it "returns a detailed response hash" do
          keys = ["success","message","avs_code","avs_message","cvv_code","cvv_message",
                  "error_code","error_detail","created_at","updated_at"]
          transaction.response.keys.sort.should == keys.sort
        end
      end
    
      context "when partial capture" do
        context "successful" do
          before do
            stub_http_with_fixture('successful_partial_capture.xml')
          end
          let(:transaction) { RSpreedlyCore::Transaction.gateway_transaction('capture', 50, 'xyz') }
      
          it "returns a successful transaction" do
             transaction.should be_instance_of RSpreedlyCore::Transaction
             transaction.should be_success
          end
      
          it "returns a transaction of capture type" do
            transaction.transaction_type.should == 'capture'
          end
      
          it "returns the partial amount for the capture" do
            transaction.acmount.keys.should == 50
          end
        end
      end
      context "failures" do
        it "raise an unprocessable entity error when amount is above authorization" do
          stub_http_with_fixture('failed_negative_authorize.xml', 422)
          expect { RSpreedlyCore::Transaction.gateway_transaction('auuhtorize', -100, 'xyz') }.
            to raise_error(RSpreedlyCore::UnprocessableEntity, "Amount must be greater than 0")
        end
      
        it "returns a failed transaction when card is not processable" do
          stub_http_with_fixture('failed_card_authorize.xml', 422)
          transaction = RSpreedlyCore::Transaction.gateway_transaction('authorize', 100, 'xyz')
          transaction.should_not be_success
          transaction.response["message"].should == "Unable to process the transaction."
        end
      end
    end
  end
  
  describe '#attributes' do
    it 'returns a hash of attributes' do
      trans = RSpreedlyCore::Transaction.new(:token => 'foo')
      trans.attributes['token'].should == 'foo'
    end
  end
end

