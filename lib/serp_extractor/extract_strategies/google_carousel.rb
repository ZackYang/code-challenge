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
            result_prefix: "https://www.google.com"
          },
          {
            name: "image",
            xpath: ".//img",
            type: :attribute,
            attribute: "src",
            handler: ->(value) { CGI.escape(value) }
          },
          {
            name: "extensions",
            xpath: ".//div[@class='ellip klmeta']",
            type: :text,
            is_array: true,
            remove_when_blank: true
          }
        ]
      end
    end
  end
end
