require "selenium-webdriver"

RSpec.describe SerpExtractor::WebContext do
  let(:page_path) { "spec/fixtures/van-gogh-paintings.html" }
  let(:web_context) { SerpExtractor::WebContext.new(SerpExtractor.path_to(page_path)) }
  let(:driver) { web_context.driver }
  let(:error_message) { "An error occurred" }

  describe "#run" do
    it "navigates to the page using the Selenium driver" do
      expect(driver).to receive(:get).with("file://#{SerpExtractor.path_to(page_path)}")
      web_context.run {}
    end

    it "calls the provided block with the Selenium driver" do
      block_called = false
      web_context.run do |driver|
        block_called = true
        expect(driver).to eq(driver)
      end
      expect(block_called).to be true
    end
  end
end
