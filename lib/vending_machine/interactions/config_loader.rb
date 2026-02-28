# frozen_string_literal: true

require 'ostruct'
require 'yaml'

module VendingMachine
  module Interactions
    # ConfigLoader handles reading, parsing YAML configuration files
    # and convert into open struct (just to make working with hashes easier)
    class ConfigLoader
      class Error < StandardError; end
      class NotFoundError < Error; end
      class ParseError < Error; end

      def initialize(config_path:)
        @config_path = config_path

        validate_file_presence!(config_path:)
      end

      def call
        data = YAML.load_file(config_path, symbolize_names: true)
        process(data)
      rescue Psych::SyntaxError => e
        raise ParseError "Failed to parse YAML file #{config_path}: #{e.message}"
      end

      private

      attr_reader :config_path

      def process(data)
        case data
        when Hash
          OpenStruct.new(data.transform_values { |value| process(value) })
        when Array
          data.map { |item| process(item) }
        else
          data
        end
      end

      def validate_file_presence!(config_path:)
        return if File.exist?(config_path)

        raise NotFoundError, "Config file not found at: #{config_path}"
      end
    end
  end
end
