require "selenium-webdriver"

module SerpExtractor
  class WebContext
    attr_reader :driver

    def initialize(page_path)
      @page_path = SerpExtractor.path_to(page_path)
      @driver = Selenium::WebDriver.for :chrome
    end

    def run(&block)
      @driver.get("file://#{@page_path}")
      block.call(@driver)
    rescue StandardError => e
      SerpExtractor.logger.error("Error running the block in the WebContext")
      SerpExtractor.logger.error(e.message)
      SerpExtractor.logger.info(e.backtrace.join("\n"))
    end
  end
end
