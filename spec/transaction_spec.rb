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

  describe ".retain" do
    before do
      stub_http_with_fixture('successful_retain.xml')
    end
    let(:transaction) { RSpreedlyCore::Transaction.retain('xyz') }

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
      RSpreedlyCore::Transaction.retain(token)
    end

  end
end
