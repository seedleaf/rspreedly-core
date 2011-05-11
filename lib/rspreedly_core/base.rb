module RSpreedlyCore
  module ApiAttributes
    def api_attributes(*attrs)
      attr_accessor *attrs if attrs
      @api_attributes ||= attrs
    end
  end

  module InstanceMethods
    def initialize(attributes)
      self.attributes = attributes
    end

    def attributes
      attrs = {}
      self.class.api_attributes.each do |attr|
        attrs[attr.to_s] = self.send(attr)
      end
      yield attrs if block_given?
      attrs
    end

    private

    def attributes=(attrs = {})
      attrs.each do |k, v|
        self.send(:"#{k}=", v) if self.respond_to?(:"#{k}=")
      end
    end
  end

  module Base
    def self.included(kls)
      kls.extend(ApiAttributes)
      kls.send(:include, InstanceMethods)
    end
  end
end
