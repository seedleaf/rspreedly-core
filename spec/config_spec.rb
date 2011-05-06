require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RSpreedlyCore::Config do

  describe "#setup" do
    it "initializes the configuration" do
      RSpreedlyCore::Config.setup do |config|
        config[:api_login] = 'site_api_login'
      end

      RSpreedlyCore::Config[:api_login].should == 'site_api_login'
    end
  end

  describe "[]=" do
    it "sets configurations" do
      RSpreedlyCore::Config[:api_login] = 'foo'
      RSpreedlyCore::Config[:api_login].should == 'foo'
    end
  end
end
