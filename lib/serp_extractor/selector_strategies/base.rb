# frozen_string_literal: true

module SerpExtractor
  class Base
    def node_set_selector
      raise NotImplementedError
    end

    def attribute_xpathes
      raise NotImplementedError
    end
  end
end
