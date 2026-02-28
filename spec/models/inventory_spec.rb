# frozen_string_literal: true

require 'ostruct'
require 'spec_helper'

RSpec.describe VendingMachine::Models::Inventory do
  let(:coca_cola_data) { OpenStruct.new(name: 'Coca Cola', price: 2.5, quantity: 5) }
  let(:water_data) { OpenStruct.new(name: 'Water', price: 1.0, quantity: 0) }
  let(:products_data) { [coca_cola_data, water_data] }

  subject(:inventory) { described_class.new(products_data: products_data) }

  describe '#initialize' do
    it 'creates product objects and sets initial quantities' do
      expect(inventory.products.keys.first).to be_a(VendingMachine::Models::Product)
      expect(inventory.products.values).to include(5, 0)
    end
  end

  describe '#find_by_name' do
    it 'finds a product by exact name (case-insensitive)' do
      expect(inventory.find_by_name('coca cola').name).to eq('Coca Cola')
    end

    it 'finds a product by a part of the name (word boundary)' do
      expect(inventory.find_by_name('coca').name).to eq('Coca Cola')
    end

    it 'returns nil for very short search strings' do
      expect(inventory.find_by_name('co')).to be_nil
    end

    it 'returns nil if product is not found' do
      expect(inventory.find_by_name('Pepsi')).to be_nil
    end
  end

  describe '#product_available?' do
    it 'returns true if product is in stock' do
      expect(inventory.product_available?('Coca Cola')).to be_truthy
    end

    it 'returns false if product quantity is zero' do
      expect(inventory.product_available?('Water')).to be_falsey
    end

    it 'returns false if product does not exist' do
      expect(inventory.product_available?('Unknown')).to be_falsey
    end
  end

  describe '#reduce_products' do
    it 'decrements the product quantity by 1' do
      expect { inventory.reduce_products('Coca Cola') }
        .to change { inventory.quantity_of('Coca Cola') }.from(5).to(4)
    end

    it 'does not decrement if the product is out of stock' do
      expect { inventory.reduce_products('Water') }
        .not_to change { inventory.quantity_of('Water') }
    end
  end

  describe '#quantity_of' do
    it 'returns the correct quantity' do
      expect(inventory.quantity_of('Coca Cola')).to eq(5)
    end

    it 'returns 0 for non-existent products' do
      expect(inventory.quantity_of('NonExistent')).to eq(0)
    end
  end
end
