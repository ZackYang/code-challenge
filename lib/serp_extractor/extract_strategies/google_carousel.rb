module SerpExtractor
  module ExtractStrategies
    class GoogleCarousel < Base
      def node_set_selector
        "//g-scrolling-carousel//a[@aria-label]"
      end

      def node_set_selector_mode
        :xpath
      end

      def attributes
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
            handler: lambda do |value|
              if value.start_with?("/")
                "https://www.google.com#{value}"
              else
                value
              end
            end
          },
          {
            name: "image",
            xpath: ".//img",
            type: :attribute,
            attribute: "src"
          },
          {
            name: "extensions",
            xpath: ".//div[@class='ellip klmeta'] | .//div[@class='cp7THd']/div[@class='FozYP']",
            type: :text,
            is_array: true,
            remove_when_blank: true
          }
        ]
      end
    end
  end
end
