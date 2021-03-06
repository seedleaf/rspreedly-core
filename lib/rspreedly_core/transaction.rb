module RSpreedlyCore
  class Transaction
    include Base

    api_attributes :token, :transaction_key, :succeeded, :transaction_type, :response,
                   :message, :created_at, :updated_at, :amount

    def self.payment_method_transaction(action, token)
      request = Request.new(:put, "/payment_methods/#{token}/#{action}.xml")
      response = request.response
      self.new(response["transaction"])
    end

    def self.gateway_transaction(action, amount, token, options = {})
      gateway_token = options[:gateway_token] || RSpreedlyCore::Config[:gateway_token]
      currency_code = options[:currency_code] || "USD"
      xml_tags = {:transaction_type => action,
                  :payment_method_token => token,
                  :amount => amount,
                  :currency_code => currency_code}
      request = Request.new(:post, "/gateways/#{gateway_token}/#{action}.xml", xml_body(xml_tags))
      response = request.response
      self.new(response["transaction"])
    end

    def self.capture_transaction(action, amount, transaction_token, options = {})
      xml_tags = amount ? {:amount => amount} : {}
      request = Request.new(:post, "/transactions/#{transaction_token}/#{action}.xml", xml_body(xml_tags))
      response = request.response
      self.new(response["transaction"])
    end

    def success?
      succeeded
    end
  end
end
