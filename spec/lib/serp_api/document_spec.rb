require 'serp_api/document'

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

  describe '#query' do
    let(:page_path) { SerpApi.path_to('files/van-gogh-paintings.html') }
    let(:selector) { '.kltat' }
    let(:node_content) { 'The Starry Night' }
    let(:html) { File.open(page_path, 'r').read }

    before do
      allow(File).to receive(:open).with(page_path).and_return(html)
    end

    context 'when mode is :css' do
      it 'returns a Nokogiri::XML::NodeSet' do
        expect(SerpApi::Document.new(page_path).query(selector, :css)[0].content).to eq(node_content)
      end
    end

    context 'when mode is :xpath' do
      let(:image_url) { 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQq3gOqqnprlNb3SdEgrKAR_0sWrsu0kO0aNnwE3yRwmA_cf-PvBvdz4eInim3FDmRn7E0' }

      it 'returns a Nokogiri::XML::NodeSet' do
        value = SerpApi::Document.new(page_path).query('//div/div/g-img/img', :xpath)[0].attribute_nodes.find do |node|
          node.name == 'data-key'
        end.value

        expect(value).to eq(image_url)
      end
    end
  end
end
