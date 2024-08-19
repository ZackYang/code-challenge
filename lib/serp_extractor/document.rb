require "nokogiri"

module SerpExtractor
  class Document
    attr_reader :doc, :elements

    def initialize(page_path)
      @page_path = page_path
      @elements = []
      load_page
    end

    def query(selector, mode = :css)
      case mode
      when :css
        @elements = @doc.css(selector)
      when :xpath
        @elements = @doc.xpath(selector)
      end
      @elements = @elements.map { |element| Element.new(element) }
    end

    def self.load(page_path)
      new(page_path).doc
    rescue StandardError => e
      SerpExtractor.logger.error(e.message)
      false
    end

    private

    def load_page
      @doc = Nokogiri::HTML.parse(File.open(@page_path))
    end
  end
end
