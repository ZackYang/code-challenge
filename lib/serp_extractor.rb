# frozen_string_literal: true

require "logger"
require "pry"

# SerpExtractor module
module SerpExtractor
  VERSION = "1.0.0"

  class << self
    attr_accessor :logger, :root_path
  end

  self.logger = Logger.new($stdout)
  logger.level = Logger::INFO
  self.root_path = File.expand_path("..", __dir__)

  def self.path_to(*path)
    # Check if the path is already absolute
    return path if path.first.start_with?("/")

    File.join(root_path, *path)
  end

  def self.extract(file_path, strategy: nil)
    Document.new(file_path).extract_by_strategy(strategy)
  end
end

require_relative "serp_extractor/web_context"
require_relative "serp_extractor/element"
require_relative "serp_extractor/document"
require_relative "serp_extractor/extract_strategies/base"
require_relative "serp_extractor/extract_strategies/google_carousel"
