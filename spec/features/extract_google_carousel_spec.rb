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
    elements.each_with_index do |element, index|
      expect(element[:link]).to eq(expected_array[index][:link])
      expect(element[:name]).to eq(expected_array[index][:name])
      expect(element[:extensions]).to eq(expected_array[index][:extensions])
      # as the image is expected encoded, we need to compare the decoded version
      expect(element[:image]&.gsub('//2Q==', '//2Qx3dx3d')).to eq(expected_array[index][:image])
    end
  end
end
