module RSpreedlyCore
  class Transaction
    API_ATTRIBUTES = [:token, :transaction_key, :succeeded, :transaction_type]

    include Base

    def self.retain(token)
      request = Request.new(:put, "/payment_methods/#{token}/retain.xml")
      response = request.response
      self.new(response["transaction"])
    end

    def success?
      succeeded
    end
  end
end
