require_relative '../../../lib/serp_api/document'

RSpec.describe SerpApi::Document do
  describe '.load' do
    let(:page_path) { '/path/to/page.html' }
    let(:document) { double('Nokogiri::HTML::Document') }

    before do
      allow(File).to receive(:open).with(page_path).and_return('<html><body></body></html>')
      allow(Nokogiri::HTML).to receive(:parse).and_return(document)
    end

    it 'loads the page using Nokogiri::HTML' do
      expect(Nokogiri::HTML).to receive(:parse).with('<html><body></body></html>')
      SerpApi::Document.load(page_path)
    end

    it 'returns the loaded document' do
      expect(SerpApi::Document.load(page_path)).to eq(document)
    end

    context 'when an error occurs during page loading' do
      before do
        allow(Nokogiri::HTML).to receive(:parse).and_raise('Failed to load page')
      end

      it 'returns a nil' do
        expect(SerpApi::Document.load(page_path)).to be_falsey
      end
    end
  end
end
