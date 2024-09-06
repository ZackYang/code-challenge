require "json"

RSpec.describe "Extract Google Carousel" do
  let(:strategy) { SerpExtractor::ExtractStrategies::GoogleCarousel.new }
  let(:document) { SerpExtractor::Document.new(page_path) }
  let!(:expected_array) do
    JSON.parse(File.read(SerpExtractor.path_to("spec/fixtures/expected-array.json")))
  end

  context "when page is Van Gogh paintings" do
    let(:page_path) { SerpExtractor.path_to("spec/fixtures/van-gogh-paintings.html") }

    it "extracts the elements using the strategy" do
      elements = document.extract_by_strategy(strategy)
      elements.each_with_index do |element, index|
        expect(element[:link]).to eq(expected_array[index][:link])
        expect(element[:name]).to eq(expected_array[index][:name])
        expect(element[:extensions]).to eq(expected_array[index][:extensions])
        # as the image is expected encoded, we need to compare the decoded version
        expect(element[:image]&.gsub("//2Q==", "//2Qx3dx3d")).to eq(expected_array[index][:image])
      end
    end
  end

  context "when page is not New Zealand prime ministers" do
    let(:page_path) { SerpExtractor.path_to("spec/fixtures/new-zealand-prime-ministers.html") }
    let(:link) { "https://www.google.com/search?sca_esv=5f833fc7e19dbbb8&q=Christopher+Luxon&stick=H4sIAAAAAAAAAONgFmJQ4tLP1TfIM03LyivWEglKTU7NKwkoysxN9c3MyywuSS0qfsTowS3w8sc9YSn7SWtOXmO05MKqTEiSi8MnPzmxJDM_T4hXipuLE2Rwckl5fJIVkwZTFRMHI88iVkHnjCKg-vyCjNQiBZ_Sivy8CWyMAJHxQteIAAAA&sa=X&ved=2ahUKEwi3m6fQifqHAxWIZ_UHHfsaASAQ-BZ6BAg0EAc" }

    it "does not extract any element" do
      elements = document.extract_by_strategy(strategy)
      expect(elements.size).to eq(49)
      first_element = elements.first
      puts first_element
      expect(first_element["link"]).to eq(link)
      expect(first_element["name"]).to eq("Christopher Luxon")
      expect(first_element["extensions"]).to eq(["2023-"])
      expect(first_element["image"]).to start_with("data:image/png;base64")
    end
  end
end
