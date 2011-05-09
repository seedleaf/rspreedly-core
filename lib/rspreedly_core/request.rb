module RSpreedlyCore
  class Request
    include HTTParty
    format :xml
    base_uri "https://spreedlycore.com/v1"

    attr_reader :response, :attributes

    def initialize(method, path)
      @method = method
      @path = path
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
          }, :body => ""
      }

      @response = self.class.send(@method, @path, options)
      handle_response_errors
    end

    def handle_response_errors
      raise RSpreedlyCore::InvalidCredentials if @response.code == 401
      raise RSpreedlyCore::TokenNotFound if @response.code == 404
    end
  end
end
