module RSpreedlyCore
  class Base

    API_ATTRIBUTES = []
    attr_accessor *API_ATTRIBUTES

    def initialize(attributes)
      self.attributes = attributes
    end

    def attributes
      attrs = {}
      API_ATTRIBUTES.each do |attr|
        attrs[attr.to_s] = self.send(attr)
      end
      yield attrs
      attrs
    end

    private

    def attributes=(attrs = {})
      attrs.each do |k, v|
        self.send(:"#{k}=", v) if self.respond_to?(:"#{k}=")
      end
    end
  end
end
