# frozen_string_literal: true

module SerpExtractor
  module ExtractStrategies
    class Base
      def node_set_selector
        raise NotImplementedError
      end

      def attribute_xpathes
        raise NotImplementedError
      end
    end
  end
end
