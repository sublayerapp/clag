module Sublayer
  module Components
    class OutputFunction
      include Sublayer::Components

      attr_reader :name

      def self.create(options)
        ("Sublayer::Components::"+options[:type].to_s.camelize).constantize.new(options)
      end

      def to_hash
        # Raise not implemented error
        raise NotImplementedError
      end

      def to_xml
        raise NotImplementedError
      end
    end
  end
end
