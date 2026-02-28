# frozen_string_literal: true

require 'yaml'

require_relative '../models/product'
require_relative '../models/inventory'
require_relative '../models/till'
require_relative '../interactions/config_loader'
require_relative '../interactions/composer'
require_relative '../interactions/output'

module VendingMachine
  module Helpers
    # Utils contains helper methods to load config files and load deps.
    module Utils
      CONFIG_FILE_NAMES = %i[texts products coins].freeze

      def config_path(config_file_name:)
        "config/#{config_file_name}.yml"
      end

      def load_configs
        @configs = CONFIG_FILE_NAMES.to_h do |config_file_name|
          [
            config_file_name,
            Interactions::ConfigLoader.new(config_path: config_path(config_file_name:)).call
          ]
        end
      end

      def load_dependencies
        @inventory = Models::Inventory.new(products_data: @configs[:products])
        @till = Models::Till.new(initial_coins: @configs[:coins])
        @composer = Interactions::Composer.new(inventory: @inventory, till: @till)
        @output = Interactions::Output.new(
          inventory: @inventory,
          texts: @configs[:texts],
          io: $stdout
        )
      end
    end
  end
end
