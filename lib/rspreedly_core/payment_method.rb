module RSpreedlyCore

  class TokenNotFound < StandardError; nil; end
  class InvalidCredentials < StandardError; nil; end

  class PaymentMethod

    API_ATTRIBUTES = [:token, :number, :verification_value, :month, :year,
      :first_name, :last_name, :card_type, :address1,
      :address2, :city, :state, :zip, :country, :phone_number, :email ]

    attr_accessor *API_ATTRIBUTES
    attr_reader :errors, :response

    def initialize(token)
      @response = Request.new(token).response
      @payment_method_attributes = @response["payment_method"]

      if @payment_method_attributes
        self.attributes = @payment_method_attributes
      end

      set_errors
    end

    def attributes
      attrs = {}
      API_ATTRIBUTES.each do |attr|
        attrs[attr.to_s] = self.send(attr)
      end
      attrs["errors"] = @errors
      attrs
    end

    private

    def attributes=(attrs)
      attrs.each do |k, v|
        self.send(:"#{k}=", v) if self.respond_to?(:"#{k}=")
      end
    end

    def set_errors
      @errors = []
      existing_errors = @payment_method_attributes["errors"]
      if existing_errors
        errors = existing_errors["error"]
        if errors.is_a?(Array)
          errors.each {|error| set_error(error)}
        elsif errors.is_a?(String)
          set_error(errors)
        else
          nil
        end
      end
    end

    def set_error(error)
      attributes = error.attributes
      @errors << { attributes['attribute'] => {
        'key' => attributes['key'], 'message' => error
        }
      }
    end
  end

  class Request
    include HTTParty
    format :xml
    base_uri "https://spreedlycore.com/v1"

    attr_reader :response, :attributes

    def initialize(token)
      do_request(token)
    end

    private
    def do_request(token)
      options = {
        :basic_auth => {
          :username => RSpreedlyCore::Config[:api_login],
          :password => RSpreedlyCore::Config[:api_secret]},
          :headers  => {
            "Content-Type" => 'application/xml'
          }
      }

      @response = self.class.get("/payment_methods/#{token}.xml",options)
      handle_response_errors
    end

    def handle_response_errors
      raise RSpreedlyCore::InvalidCredentials if @response.code == 401
      raise RSpreedlyCore::TokenNotFound if @response.code == 404
    end
  end
end
