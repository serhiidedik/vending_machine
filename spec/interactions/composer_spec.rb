# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VendingMachine::Interactions::Composer do
  let(:inventory) { instance_double(VendingMachine::Models::Inventory) }
  let(:till) { instance_double(VendingMachine::Models::Till) }
  let(:product) { instance_double(VendingMachine::Models::Product, name: 'Cola', price_cents: 100) }

  subject(:composer) { described_class.new(inventory: inventory, till: till) }

  describe '#add_coin' do
    context 'when denomination is acceptable' do
      before { allow(till).to receive(:acceptable_denomination?).with(25).and_return(true) }

      it 'returns success status' do
        result = composer.add_coin(0.25)
        expect(result).to include(status: :success, message: :insert, data: 25)
      end

      it 'updates the inserted balance' do
        expect { composer.add_coin(0.25) }.to change { composer.current_balance }.by(25)
      end
    end

    context 'when denomination is not acceptable' do
      before { allow(till).to receive(:acceptable_denomination?).with(1300).and_return(false) }

      it 'returns error status and does not update balance' do
        result = composer.add_coin(13)
        expect(result).to include(status: :error, message: :unacceptable)
        expect(composer.current_balance).to eq(0)
      end
    end
  end

  describe '#select_product' do
    it 'returns error if product is not found' do
      allow(inventory).to receive(:find_by_name).and_return(nil)
      expect(composer.select_product('Pepsi')).to include(status: :error, message: :not_found)
    end

    it 'returns error if product is out of stock' do
      allow(inventory).to receive(:find_by_name).with('Cola').and_return(product)
      allow(inventory).to receive(:product_available?).with('Cola').and_return(false)

      expect(composer.select_product('Cola')).to include(status: :error, message: :out_of_stock)
    end

    it 'sets selected product and returns success' do
      allow(inventory).to receive(:find_by_name).with('Cola').and_return(product)
      allow(inventory).to receive(:product_available?).with('Cola').and_return(true)

      result = composer.select_product('Cola')
      expect(result).to include(status: :success, message: :selected, data: product)
      expect(composer.selected_product).to eq(product)
    end
  end

  describe '#buy' do
    before do
      allow(composer).to receive(:selected_product).and_return(product)
      composer.instance_variable_set(:@inserted_coins, { 100 => 1, 25 => 1 })
    end

    it 'returns error if no product is selected' do
      allow(composer).to receive(:selected_product).and_return(nil)
      expect(composer.buy).to include(status: :error, message: :no_product_selected)
    end

    it 'returns error if funds are insufficient' do
      composer.instance_variable_set(:@inserted_coins, { 25 => 1 })
      expect(composer.buy).to include(status: :error, message: :insufficient_funds)
    end

    context 'when purchase is valid' do
      let(:change) { { 25 => 1 } }

      before do
        allow(till).to receive(:calculate_change).with(25).and_return(change)
        allow(inventory).to receive(:reduce_products).with('Cola')
        allow(till).to receive(:add_coins)
        allow(till).to receive(:dispense_change).with(change)
      end

      it 'finalizes transaction and resets session' do
        result = composer.buy
        expect(result[:status]).to eq(:success)
        expect(result[:data][:change]).to eq(change)
        expect(composer.current_balance).to eq(0)
      end
    end

    context 'when machine cannot provide change' do
      it 'refunds inserted coins as per requirements' do
        allow(till).to receive(:calculate_change).with(25).and_return(nil)

        result = composer.buy
        expect(result).to include(status: :success, message: :insufficient_funds, data: 125)
        expect(composer.current_balance).to eq(0)
      end
    end
  end

  describe '#cancel' do
    it 'returns refund and resets session' do
      composer.instance_variable_set(:@inserted_coins, { 50 => 2 })

      result = composer.cancel
      expect(result).to include(status: :success, message: :refund, data: 100)
      expect(composer.current_balance).to eq(0)
    end
  end
end
