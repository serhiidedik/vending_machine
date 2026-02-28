# frozen_string_literal: true

module VendingMachine
  module Models
    # Represents the vending machine's cash register,
    # is responsible for coin inventory management and optimal change calculation.
    # It ensures financial accuracy through the use of integer logic and includes a greedy coin dispensing algorithm.
    class Till
      attr_reader :coins

      def initialize(initial_coins:)
        @coins = initial_coins.to_h { |coin| [(coin.value * 100).to_i, coin.quantity] }
      end

      def acceptable_denomination?(cents)
        coins.keys.include?(cents)
      end

      def add_coins(inserted_hash)
        inserted_hash.each do |denomination, count|
          coins[denomination] += count
        end
      end

      def calculate_change(amount_cents)
        return {} if amount_cents.zero?

        change = Hash.new(0)
        remaining = amount_cents
        temp_coins = coins.dup

        available_denominations.each do |denomination|
          while remaining >= denomination && temp_coins[denomination].positive?
            remaining -= denomination
            temp_coins[denomination] -= 1
            change[denomination] += 1
          end
        end

        remaining.zero? ? change : nil
      end

      def dispense_change(change_hash)
        change_hash.each do |denomination, count|
          coins[denomination] -= count
        end
      end

      private

      def available_denominations
        coins.keys.sort.reverse
      end
    end
  end
end
