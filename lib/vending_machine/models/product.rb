# frozen_string_literal: true

module VendingMachine
  module Models
    # Represents a product definition in the system.
    class Product
      attr_reader :name, :price, :price_cents

      def initialize(name:, price:)
        @name = name
        @price = price
        @price_cents = (price.to_f * 100).to_i
      end

      def to_s
        name
      end
    end
  end
end
