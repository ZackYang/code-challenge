# frozen_string_literal: true

require 'logger'

module SerpApi
  VERSION = '1.0.0'

  class << self
    attr_accessor :logger
  end

  self.logger = Logger.new(STDOUT)
  self.logger.level = Logger::INFO
end

require_relative 'serp_api/document'
