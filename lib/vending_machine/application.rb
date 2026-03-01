# frozen_string_literal: true

require_relative 'helpers/utils'

module VendingMachine
  # Application is the central entry point that coordinates configuration loading, model initialization
  # and the main interactive loop.
  class Application
    QUIT_COMMANDS = %w[exit quit q].freeze

    include Helpers::Utils

    def initialize
      load_configs
      load_dependencies

      output.render_welcome_block
    end

    def run
      loop do
        break unless process_command
      rescue Interrupt
        output.render_exit
        break
      end
    end

    private

    attr_reader :composer, :output, :till

    def process_command
      output.render_current_state(composer.current_balance, composer.selected_product)

      input = gets&.chomp&.downcase
      return output.render_exit if QUIT_COMMANDS.include?(input)

      result = execute_command(input)
      output.render_operation_status(result:) if result.is_a?(Hash)

      true
    end

    def execute_command(input)
      case input
      when 'buy' then composer.buy
      when 'cancel' then composer.cancel
      when 'help', '?' then output.render_help
      when 'menu' then output.render_menu
      # when 'till' then { status: :success, message: :info, data: till.coins }
      when 'till' then output.render_till_coins(coins: till.coins)
      when /\A[0-9]+(?:\.[0-9]{1,2})?\z/ then composer.add_coin(input)
      when '' then nil
      else composer.select_product(input)
      end
    end
  end
end

VendingMachine::Application.new.run if __FILE__ == $PROGRAM_NAME
