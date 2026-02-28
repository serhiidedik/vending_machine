# frozen_string_literal: true

module VendingMachine
  module Models
    # Inventory manages the availability and quantity of products.
    # It acts as a bridge between Product definitions and their stock levels.
    class Inventory
      attr_reader :products

      def initialize(products_data:)
        @products = products_data.to_h do |product_data|
          [
            build_product(name: product_data.name, price: product_data.price),
            product_data.quantity.to_i
          ]
        end
      end

      def find_by_name(name)
        return if name.size < 3

        products.keys.find do |product|
          product.name.downcase.match?(/\b#{Regexp.escape(name.downcase)}/)
        end
      end

      def product_names
        @products.keys.map(&:name)
      end

      def product_available?(product_name)
        product = find_by_name(product_name)
        product && @products[product].positive?
      end

      def quantity_of(product_name)
        return 0 unless product_available?(product_name)

        product = find_by_name(product_name)
        product ? @products[product] : 0
      end

      def reduce_products(product_name)
        return unless product_available?(product_name)

        product = find_by_name(product_name)
        @products[product] -= 1
      end

      private

      def build_product(name:, price:)
        VendingMachine::Models::Product.new(name:, price:)
      end
    end
  end
end
