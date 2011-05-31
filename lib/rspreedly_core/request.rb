module RSpreedlyCore
  class Request
    include HTTParty
    format :xml
    base_uri "https://spreedlycore.com/v1"

    attr_reader :response, :attributes

    def initialize(method, path, body = "")
      @method = method
      @path = path
      @body = body
      do_request
    end

    private

    def do_request
      options = {
        :basic_auth => {
          :username => RSpreedlyCore::Config[:api_login],
          :password => RSpreedlyCore::Config[:api_secret]},
          :headers  => {
            "Content-Type" => 'application/xml'
          }, :body => @body
      }
      @response = self.class.send(@method, @path, options)
      debugger
      handle_response_errors
    end

    def handle_response_errors
      raise RSpreedlyCore::InvalidCredentials if @response.code == 401
      raise RSpreedlyCore::TokenNotFound if @response.code == 404
      if @response.code == 422 && errors = @response["errors"]
        raise RSpreedlyCore::UnprocessableEntity.new(errors["error"])
      end
    end
  end
end
