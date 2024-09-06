require "selenium-webdriver"

module SerpExtractor
  class WebContext
    attr_reader :driver

    def initialize(page_path)
      @page_path = page_path
      @driver = Selenium::WebDriver.for :chrome, options: Selenium::WebDriver::Chrome::Options.new(args: %w[headless disable-gpu])
    end

    def run(&block)
      @driver.get("file://#{@page_path}")

      wait = Selenium::WebDriver::Wait.new(timeout: 10)
      wait.until { driver.execute_script('return document.readyState') == 'complete' }

      block.call(@driver)
    rescue StandardError => e
      SerpExtractor.logger.error("Error running the block in the WebContext")
      SerpExtractor.logger.error(e.message)
      SerpExtractor.logger.info(e.backtrace.join("\n"))
    end
  end
end
