# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/vending_machine/models/product'

RSpec.describe VendingMachine::Models::Product do
  subject(:product) { described_class.new(name: 'Coca Cola', price: 2.5) }

  describe '#initialize' do
    it 'sets the product name correctly' do
      expect(product.name).to eq('Coca Cola')
    end

    it 'stores the original price' do
      expect(product.price).to eq(2.5)
    end

    it 'converts the price to cents correctly' do
      expect(product.price_cents).to eq(250)
    end
  end

  describe '#price_cents' do
    context 'with float values that often cause precision issues' do
      let(:product) { described_class.new(name: 'Special Item', price: 1.1) }

      it 'handles precision and converts to integer cents' do
        expect(product.price_cents).to eq(110)
      end
    end
  end

  describe '#to_s' do
    it 'returns the name of the product' do
      expect(product.to_s).to eq('Coca Cola')
    end
  end
end
