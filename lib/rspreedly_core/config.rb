module RSpreedlyCore
  module Config
    class << self
      def setup
        yield configuration
        nil
      end

      def configuration
        @configuration ||= {}
      end

      def [](key)
        self.configuration[key]
      end
    end
  end
end
