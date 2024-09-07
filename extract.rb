# frozen_string_literal: true

require_relative "lib/serp_extractor"

page_path = ARGV[0] || "files/van-gogh-paintings.html"

page_path = SerpExtractor.path_to(page_path)

puts "Extracting from #{page_path}"

strategy = SerpExtractor::ExtractStrategies::GoogleCarousel.new
results = SerpExtractor.extract(page_path, strategy:)

puts "Extracted elements:"
puts results
