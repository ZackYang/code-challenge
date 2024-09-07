require "serp_extractor/document"

RSpec.describe SerpExtractor::Document do
  describe ".load" do
    let(:page_path) { "/path/to/page.html" }
    let(:document) { double("Nokogiri::HTML::Document") }

    before do
      allow(File).to receive(:open).with(page_path).and_return("<html><body></body></html>")
      allow(Nokogiri::HTML).to receive(:parse).and_return(document)
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
    let(:page_path) { SerpExtractor.path_to("spec/fixtures/van-gogh-paintings.html") }
    let(:css_selector) { "g-scrolling-carousel a" }
    let(:xpath_selector) { "//g-scrolling-carousel//a" }
    let(:node_content) { "The Starry Night" }
    let(:html) { File.read(page_path) }

    before do
      allow(File).to receive(:open).with(page_path).and_return(html)
    end

    context "when mode is :css" do
      it "returns am array of elements" do
        expect(SerpExtractor::Document.new(page_path).query(css_selector, :css)[0].element).to be_a(Nokogiri::XML::Element)
      end

      it "returns the content of the element with the attribute 'aria-label' equal to 'The Starry Night'" do
        value = SerpExtractor::Document.new(page_path).query(css_selector, :css)[0].element.attribute_nodes.find do |node|
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

  describe "#extract_by_strategy" do
    let(:page_path) { SerpExtractor.path_to("spec/fixtures/van-gogh-paintings.html") }
    let(:attributes) do
      [
        {
          name: "name",
          xpath: ".",
          type: :attribute,
          attribute: "aria-label"
        },
        {
          name: "link",
          xpath: ".",
          type: :attribute,
          attribute: "href",
          handler: ->(value) { "https://www.google.com#{value}" }
        },
        {
          name: "image",
          xpath: ".//g-img/img[@src]",
          type: :attribute,
          attribute: "src"
        },
        {
          name: "extensions",
          xpath: ".//div[@class='ellip klmeta']",
          is_array: true
        }
      ]
    end

    let(:strategy) do
      double(
        "Strategy",
        node_set_selector: "//g-scrolling-carousel//a[@aria-label]",
        node_set_selector_mode: :xpath,
        attributes:
      )
    end

    let(:html) { File.read(page_path) }

    before do
      allow(File).to receive(:open).with(page_path).and_return(html)
    end

    it "returns an array of hashes" do
      expect(SerpExtractor::Document.new(page_path).extract_by_strategy(strategy)).to be_an(Array)
    end

    it "returns an array of hashes with the expected keys" do
      result = SerpExtractor::Document.new(page_path).extract_by_strategy(strategy)
      keys = result[0].keys
      puts result
      expect(keys).to include("name", "link", "extensions")
      expect(result[0]["name"]).to eq("The Starry Night")
      expect(result[0]["link"]).to eq("https://www.google.com/search?gl=us&hl=en&q=The+Starry+Night&stick=H4sIAAAAAAAAAONgFuLQz9U3MI_PNVLiBLFMzC3jC7WUspOt9Msyi0sTc-ITi0qQmJnFJVbl-UXZxY8YI7kFXv64JywVMGnNyWuMXlxEaBJS4WJzzSvJLKkUkuLikYLbrcEgxcUF5_EsYhUIyUhVCC5JLCqqVPDLTM8oAQDmNFnDqgAAAA&npsic=0&sa=X&ved=0ahUKEwiL2_Hon4_hAhXNZt4KHTOAACwQ-BYILw")
      expect(result[0]["image"]).to start_with("data:image/jpeg;base64")
      expect(result[0]["extensions"]).to eq(["1889"])
    end
  end
end
