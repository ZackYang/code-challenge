require "active_support/core_ext/object/blank"

module SerpExtractor
  class Element
    attr_reader :element, :fields

    # @param element [Nokogiri::XML::Element]
    def initialize(element)
      @element = element
      @fields = {}
    end

    def extract(strategy)
      result = {}
      strategy.attributes.map do |options|
        result[options[:name]] = query_field(options)
        result[options[:name]] = apply_handler(result[options[:name]], options[:handler])
        result.delete(options[:name]) if options[:remove_when_blank] && result[options[:name]].blank?
      end
      result
    end

    def query_field(field)
      if field[:xpath].is_a?(Array)
        field[:xpath].each do |x|
          query_field(field.merge(xpath: x))
        end
      end
      node = @element.xpath(field[:xpath])
      return if @fields[field[:name]].present?

      @fields[field[:name]] = if field[:type] == :attribute
                                node.attribute(field[:attribute])&.value
                              else
                                field[:is_array] ? node.map(&:text) : node.text
                              end
    rescue StandardError => e
      SerpExtractor.logger.info("Field: #{field[:name]}")
      SerpExtractor.logger.info(@element)
      SerpExtractor.logger.error(e.message)
    end

    private

    def apply_handler(value, handler)
      return value unless handler.present?

      if value.is_a?(Array)
        value.map { |v| handler.call(v) }
      elsif value.is_a?(String)
        handler.call(value)
      else
        value
      end
    end
  end
end
