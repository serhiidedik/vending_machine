# frozen_string_literal: true

module VendingMachine
  module Interactions
    # Composer orchestrates the purchase process and manages session like a state machine.
    class Composer
      attr_reader :inventory, :till, :selected_product, :inserted_coins

      def initialize(inventory:, till:)
        @inventory = inventory
        @till = till
        @inserted_coins = Hash.new(0)
        @selected_product = nil
      end

      def add_coin(user_input)
        cents = (user_input.to_f * 100.0).to_i

        return { status: :error, message: :unacceptable, data: cents } unless till.acceptable_denomination?(cents)

        inserted_coins[cents] += 1

        { status: :success, message: :insert, data: cents }
      end

      def buy
        return { status: :error, message: :no_product_selected } unless selected_product
        return { status: :error, message: :insufficient_funds } if current_balance < selected_product.price_cents

        process_purchase
      end

      def cancel
        refund = current_balance
        reset_session

        { status: :success, message: :refund, data: refund }
      end

      def current_balance
        inserted_coins.sum { |value, count| value * count }
      end

      def select_product(product_name)
        product = inventory.find_by_name(product_name)

        return { status: :error, message: :not_found } unless product
        return { status: :error, message: :out_of_stock } unless inventory.product_available?(product_name)

        @selected_product = product

        { status: :success, message: :selected, data: product }
      end

      private

      def finalize_transaction(change)
        update_machine_state(change)

        product = selected_product.dup
        reset_session

        { status: :success, message: :done, data: { product:, change: } }
      end

      def process_purchase
        change_amount = current_balance - selected_product.price_cents

        change_result = till.calculate_change(change_amount)

        return refund_due_to_no_change if change_result.nil? && change_amount.positive?

        finalize_transaction(change_result)
      end

      def refund_due_to_no_change
        refund_amount = current_balance
        reset_session

        { status: :success, message: :insufficient_funds, data: refund_amount }
      end

      def reset_session
        @inserted_coins = Hash.new(0)
        @selected_product = nil
      end

      def update_machine_state(change)
        inventory.reduce_products(selected_product.name)
        till.add_coins(inserted_coins)
        till.dispense_change(change)
      end
    end
  end
end
