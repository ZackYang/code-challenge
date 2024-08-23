require "json"

RSpec.describe "Extract Google Carousel" do
  let(:page_path) { SerpExtractor.path_to("spec/fixtures/van-gogh-paintings.html") }
  let(:strategy) { SerpExtractor::ExtractStrategies::GoogleCarousel.new }
  let(:document) { SerpExtractor::Document.new(page_path) }
  let!(:expected_array) do
    JSON.parse(File.read(SerpExtractor.path_to("spec/fixtures/expected-array.json")))
  end

  it "extracts the elements using the strategy" do
    elements = document.extract_by_strategy(strategy)
    expect(elements.first).to eq(expected_array.first)
  end
end
