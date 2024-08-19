module SerpExtractor
  class GoogleCarousel < Base
    def node_set_selector
      "//g-scrolling-carousel//a"
    end

    def attributes
      {
        name: {
          xpath: './/div[@jsname="p7L8H"]/text()',
          is_array: false,
          type: :text
        },
        link: {
          xpath: ".//a/@href",
          type: :attribute,
          is_array: false,
          attribute: "href"
        },
        image: {
          xpath: ".//g-img/img/@src",
          type: :attribute,
          is_array: false,
          attribute: "src"
        },
        extensions: {
          xpath: './/div[@jsname="s2gQvd"]/div[@jsname="s2gQvd"]/text()',
          is_array: true,
          type: :text
        }
      }
    end
  end
end
