# frozen_string_literal: true

module VendingMachine
  module Interactions
    # The presentation layer responsible for formatting data and managing all CLI-based user interactions.
    class Output
      COLUMN_WIDTH = 25
      CURRENCY_SYMBOL = '$'
      DEFAULT_DELIMITER = '#'
      LINE_WIDTH = 100
      SECONDARY_DELIMITER = '-'

      attr_reader :inventory, :texts, :io

      def initialize(inventory:, texts:, io:)
        @inventory = inventory
        @texts = texts
        @io = io
      end

      def products_menu
        menu_lines = inventory.products.map do |product, _quantity|
          row = format_product_row_values(product).map { |value| value.to_s.ljust(COLUMN_WIDTH) }
          row.join('|')
        end

        menu_lines.join("\n")
      end

      def render_balance(cents:)
        io.puts("#{texts.messages.balance}: #{format_money(cents)}")
      end

      def render_current_state(cents, product)
        render_balance(cents:) if cents.to_i > 0
        render_selected_product(product:)
        render_delimiter(symbol: SECONDARY_DELIMITER)
        io.print('> ')
      end

      def render_delimiter(symbol: DEFAULT_DELIMITER)
        io.puts(symbol * LINE_WIDTH)
      end

      def render_exit
        io.puts(texts.messages.exit)

        false
      end

      def render_help
        io.puts("# #{texts.instructions.to_h.values.join(' | ')}")
      end

      def render_menu
        render_menu_header
        io.puts(products_menu)
        render_delimiter
      end

      def render_menu_header
        columns = texts.header.to_h.values.map { |value| value.name.ljust(COLUMN_WIDTH) }

        io.puts(columns.join('|'))
        render_delimiter(symbol: SECONDARY_DELIMITER)
      end

      def render_operation_status(result:)
        return false unless result

        io.puts(formatted_message(result:))
      end

      def render_selected_product(product:)
        return unless product

        io.puts("#{texts.messages.selected}: #{format_product(product)}")
      end

      def render_till_coins(coins:)
        io.puts(coins.to_s)
      end

      def render_welcome_block
        render_welcome_message
        render_menu
        render_help
      end

      def render_welcome_message
        render_delimiter
        io.puts(texts.welcome_message.center(LINE_WIDTH, '='))
        render_delimiter
      end

      private

      def formatted_message(result:)
        message_parts = []
        message_parts << texts.messages.public_send(result[:status])
        message_parts << texts.messages.public_send(result[:message])
        message_parts << formatted_data(data: result[:data]) if result[:data]

        message_parts.join(' ')
      end

      def format_money(cents)
        "#{CURRENCY_SYMBOL}#{format('%.2f', cents / 100.0)}"
      end

      def format_product(product)
        "#{product.name} (#{format_money(product.price_cents)})"
      end

      def format_product_row_values(product)
        [
          product.name,
          format_money(product.price_cents),
          inventory.quantity_of(product.name)
        ]
      end

      def formatted_data(data:)
        case data
        when Integer then format_money(data)
        when VendingMachine::Models::Product then format_product(data)
        when Hash then formatted_hash_data(data:)
        else data
        end
      end

      def formatted_hash_data(data:)
        return format_product_with_change(**data) if data.keys == %i[product change]

        data.to_s
      end

      def format_product_with_change(product:, change:)
        coins_list = change.flat_map { |denomination, count| [format_money(denomination)] * count }

        "#{format_product(product)}, #{texts.messages.change} #{coins_list.join(', ')}"
      end
    end
  end
end
