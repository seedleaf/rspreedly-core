module RSpreedlyCore
  module Base
    API_ATTRIBUTES = []
    def self.included(kls)
      unless kls.const_defined?(:API_ATTRIBUTES)
        raise "must define API_ATTRIBUTES before including"
      end
      kls.class_eval do
        attr_accessor *kls::API_ATTRIBUTES

        define_method :attributes do
          get_attributes(kls)
        end
      end
    end

    def initialize(attributes)
      self.attributes = attributes
    end

    private

    def get_attributes(kls=nil)
      attrs = {}
      kls::API_ATTRIBUTES.each do |attr|
        attrs[attr.to_s] = self.send(attr)
      end
      yield attrs if block_given?
      attrs
    end

    def attributes=(attrs = {})
      attrs.each do |k, v|
        self.send(:"#{k}=", v) if self.respond_to?(:"#{k}=")
      end
    end
  end
end
