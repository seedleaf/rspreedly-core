require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RSpreedlyCore::Gateway do
  context "adding test gateway" do
    before do
      stub_http_with_fixture('add_test_gateway.xml')
    end
    let(:gateway) { RSpreedlyCore::Gateway.add("test")}
    it "returns the token for the gateway" do
      gateway.token.should_not be nil
    end
    
    it "returns the characteristics of the test gateway" do
      characteristics = ["supports_purchase", "supports_authorize", "supports_capture", 
                          "supports_credit", "supports_void"].sort
      gateway.characteristics.keys.sort.should == characteristics
    end
  end
end