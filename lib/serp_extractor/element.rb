require "active_support/core_ext/object/blank"

module SerpExtractor
  class Element
    attr_reader :element, :fields

    # @param element [Nokogiri::XML::Element]
    def initialize(element)
      @element = element
      @fields = {}
    end

    def query_field(field)
      name = field[:name]
      xpath = field[:xpath]
      type = field[:type]
      is_array = field[:is_array]

      if xpath.is_a?(Array)
        xpath.each do |x|
          query_field(name:, xpath: x, type:, is_array:)
        end
      end

      node = @element.xpath(xpath)
      return if @fields[name].present?

      @fields[name] = if type == :attribute
                        node.attribute(field[:attribute]).value
                      else
                        is_array ? node.map(&:text) : node.text
                      end
    end
  end
end
