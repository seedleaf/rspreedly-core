module RSpreedlyCore
  class Gateway
    include Base

    api_attributes :token, :login, :characteristics, :mode, :created_at, :updated_at
    
    def self.add(gateway_type, options = {})
      xml_tags = options.merge(:gateway_type => gateway_type)
      body = xml_body(xml_tags)
      request = Request.new(:post, "/gateways.xml", xml_body(xml_tags))
      response = request.response
      self.new(response["gateway"])
    end  
  end
end
