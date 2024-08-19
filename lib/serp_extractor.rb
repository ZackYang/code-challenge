# frozen_string_literal: true

require "logger"
require "pry"

# SerpExtractor module
module SerpExtractor
  VERSION = "1.0.0"

  class << self
    attr_accessor :logger, :root_path
  end

  self.logger = Logger.new(STDOUT)
  logger.level = Logger::INFO
  self.root_path = File.expand_path("..", __dir__)

  def self.path_to(*path)
    File.join(root_path, *path)
  end
end

require_relative "serp_extractor/element"
require_relative "serp_extractor/document"
