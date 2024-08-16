require 'nokogiri'

module SerpApi
  class Document
    attr_reader :doc

    def initialize(page_path)
      @page_path = page_path
      load_page
    end

    def query(selector, mode = :css)
      if mode == :css
        @doc.css(selector)
      elsif mode == :xpath
        @doc.xpath(selector)
      end
    end

    def self.load(page_path)
      new(page_path).doc

      rescue => e
        SerpApi.logger.error(e.message)
        return false
    end

    private

    def load_page
      @doc = Nokogiri::HTML.parse(File.open(@page_path))
    end
  end
end
