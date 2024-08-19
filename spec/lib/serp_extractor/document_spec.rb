require "serp_extractor/document"

RSpec.describe SerpExtractor::Document do
  describe ".load" do
    let(:page_path) { "/path/to/page.html" }
    let(:document) { double("Nokogiri::HTML::Document") }

    before do
      allow(File).to receive(:open).with(page_path).and_return("<html><body></body></html>")
      allow(Nokogiri::HTML).to receive(:parse).and_return(document)
    end

    it "loads the page using Nokogiri::HTML" do
      expect(Nokogiri::HTML).to receive(:parse).with("<html><body></body></html>")
      SerpExtractor::Document.load(page_path)
    end

    it "returns the loaded document" do
      expect(SerpExtractor::Document.load(page_path)).to eq(document)
    end

    context "when an error occurs during page loading" do
      before do
        allow(Nokogiri::HTML).to receive(:parse).and_raise("Failed to load page")
      end

      it "returns a nil" do
        expect(SerpExtractor::Document.load(page_path)).to be_falsey
      end
    end
  end

  describe "#query" do
    let(:page_path) { SerpExtractor.path_to("/spec/fixtures/van-gogh-paintings.html") }
    let(:css_selector) { "g-scrolling-carousel a" }
    let(:xpath_selector) { "//g-scrolling-carousel//a" }
    let(:node_content) { "The Starry Night" }
    let(:html) { File.read(page_path) }

    before do
      allow(File).to receive(:open).with(page_path).and_return(html)
    end

    context "when mode is :css" do
      it "returns am array of elements" do
        expect(SerpExtractor::Document.new(page_path).query(css_selector)[0].element).to be_a(Nokogiri::XML::Element)
      end

      it "returns the content of the element with the attribute 'aria-label' equal to 'The Starry Night'" do
        value = SerpExtractor::Document.new(page_path).query(css_selector)[0].element.attribute_nodes.find do |node|
          node.name == "aria-label"
        end.value

        expect(value).to eq(node_content)
      end
    end

    context "when mode is :xpath" do
      it "returns an array of elements" do
        expect(SerpExtractor::Document.new(page_path).query(xpath_selector, :xpath)[0].element).to be_a(Nokogiri::XML::Element)
      end

      it "returns the content of the element with the attribute 'aria-label' equal to 'The Starry Night'" do
        value = SerpExtractor::Document.new(page_path).query(xpath_selector, :xpath)[0].element.attribute_nodes.find do |node|
          node.name == "aria-label"
        end.value

        expect(value).to eq(node_content)
      end
    end
  end
end
