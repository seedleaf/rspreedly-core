module RSpreedlyCore

  class TokenNotFound < StandardError; nil; end
  class InvalidCredentials < StandardError; nil; end

  class PaymentMethod
    include Base

    api_attributes :token, :number, :verification_value, :month, :year,
      :first_name, :last_name, :card_type, :address1,
      :address2, :city, :state, :zip, :country, :phone_number, :email

    attr_reader :errors, :response

    def self.validate(token)
      path = "/payment_methods/#{token}.xml"
      @response = Request.new(:get, path).response
      self.new(@response["payment_method"])
    end

    def retain
      RSpreedlyCore::Transaction.retain(token)
    end

    def self.retain(token)
      RSpreedlyCore::Transaction.retain(token)
    end

    def attributes
      super do |attributes|
        attributes["errors"] = @errors
      end
    end

    private

    def attributes=(attrs)
      super
      set_errors(attrs["errors"])
    end

    def set_errors(existing_errors)
      @errors = []
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
end
