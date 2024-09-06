require "nokogiri"

module SerpExtractor
  class Document
    attr_reader :doc

    def initialize(page_path)
      @page_path = page_path
      load_page
    end

    # pasring_strategy should contains the following
    # {
    #   node_set_selector: XPATH | CSS_SELECTOR,
    #   node_set_selector_mode: :xpath | :css,
    #   attributes: {
    #     attribute_name: {
    #       xpath: xpath,
    #       is_array: true | false,
    #       type: :text | :attribute,
    #       attribute: attribute_name
    #     }
    #   }
    # }
    #  please refer to lib/serp_extractor/selector_strategies/google_carousel.rb for an example
    def extract_by_strategy(strategy)
      elements = query(strategy.node_set_selector, strategy.node_set_selector_mode)
      elements.map do |element|
        element.extract(strategy)
      end
    end

    # returns an array of Element objects that match the selector
    def query(selector, mode = :xpath)
      elements = []
      case mode
      when :css
        elements = @doc.css(selector)
      when :xpath
        elements = @doc.xpath(selector)
      end
      elements.map { |element| Element.new(element) }
    end

    def self.load(page_path)
      new(page_path).doc
    rescue StandardError => e
      SerpExtractor.logger.error(e.message)
      false
    end

    private

    def load_page
      WebContext.new(@page_path).run do |driver|
        @doc = Nokogiri::HTML.parse(driver.page_source, nil, "utf-8")
      end
    end
  end
end
