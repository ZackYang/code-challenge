require "serp_extractor/element"

RSpec.describe SerpExtractor::Element do
  let(:element_html) do
    <<-HTML
    <a class="klitem" aria-label="The Starry Night" aria-posinset="1" aria-setsize="51" data-sp="0,17,26" href="/search?gl=us&amp;hl=en&amp;q=The+Starry+Night&amp;stick=H4sIAAAAAAAAAONgFuLQz9U3MI_PNVLiBLFMzC3jC7WUspOt9Msyi0sTc-ITi0qQmJnFJVbl-UXZxY8YI7kFXv64JywVMGnNyWuMXlxEaBJS4WJzzSvJLKkUkuLikYLbrcEgxcUF5_EsYhUIyUhVCC5JLCqqVPDLTM8oAQDmNFnDqgAAAA&amp;npsic=0&amp;sa=X&amp;ved=0ahUKEwiL2_Hon4_hAhXNZt4KHTOAACwQ-BYILw" style="height:193px;width:120px" title="The Starry Night (1889)" role="button" data-hveid="47" data-ved="0ahUKEwiL2_Hon4_hAhXNZt4KHTOAACwQ-BYILw">
      <div class="klzc" style="margin-bottom:0">
          <div class="klic" style="height:120px;width:120px">
            <g-img class="BA0A6c" style="height:120px;width:120px">
              <img src="data:image/jpeg;base64,/9j" data-key="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQq3gOqqnprlNb3SdEgrKAR_0sWrsu0kO0aNnwE3yRwmA_cf-PvBvdz4eInim3FDmRn7E0" id="kximg0"
            </g-img>
          </div>
      </div>
      <div>
          <div class="kltat">
            <span>The Starry </span>
            <wbr>
            <span>Night</span>
            <wbr>
          </div>
          <div class="ellip klmeta">1889</div>
      </div>
    </a>
    HTML
  end

  let(:element) { Nokogiri::XML(element_html).children.first }
  subject { described_class.new(element) }

  describe "#query_field" do
    context "when query an attribute" do
      let(:field_strategy) do
        {
          name: "name",
          xpath: "//a[@aria-label]",
          type: :attribute,
          attribute: "aria-label"
        }
      end

      it "returns the value of the attribute 'aria-label'" do
        expect(subject.query_field(field_strategy)).to eq("The Starry Night")
      end
    end

    context "when query a text" do
      let(:field_strategy) do
        {
          name: "name",
          xpath: "//div[@class='kltat']//span",
          type: :text
        }
      end

      it "returns the text of the element" do
        expect(subject.query_field(field_strategy)).to eq("The Starry Night")
      end
    end

    context "when query an array" do
      let(:field_strategy) do
        {
          name: "extensions",
          xpath: "//div[@class='ellip klmeta']",
          type: :text,
          is_array: true
        }
      end

      it "returns an array of texts" do
        expect(subject.query_field(field_strategy)).to eq(["1889"])
      end
    end

    context "when has multiple xpathes" do
      let(:field_strategy) do
        {
          name: "year",
          xpath: ["//div[@class='invalid']", "//div[@class='ellip klmeta']"],
          type: :text
        }
      end

      it "ignores the first xpath and return the result of the second" do
        subject.query_field(field_strategy)

        expect(subject.fields["year"]).to eq("1889")
      end
    end
  end

  describe "#extract" do
    let(:strategy) { double(attributes: strategy_attributes) }
    let(:strategy_attributes) do
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
          xpath: ".//div/g-img/img[@src]",
          type: :attribute,
          attribute: "src"
        },
        {
          name: "extensions",
          xpath: ".//div[@class='ellip klmeta']",
          type: :text,
          is_array: true
        }
      ]
    end

    it "returns a hash with the extracted fields" do
      expect(subject.extract(strategy)).to eq(
        {
          "name" => "The Starry Night",
          "link" => "https://www.google.com/search?gl=us&hl=en&q=The+Starry+Night&stick=H4sIAAAAAAAAAONgFuLQz9U3MI_PNVLiBLFMzC3jC7WUspOt9Msyi0sTc-ITi0qQmJnFJVbl-UXZxY8YI7kFXv64JywVMGnNyWuMXlxEaBJS4WJzzSvJLKkUkuLikYLbrcEgxcUF5_EsYhUIyUhVCC5JLCqqVPDLTM8oAQDmNFnDqgAAAA&npsic=0&sa=X&ved=0ahUKEwiL2_Hon4_hAhXNZt4KHTOAACwQ-BYILw",
          "image" => "data:image/jpeg;base64,/9j",
          "extensions" => ["1889"]
        }
      )
    end
  end
end
