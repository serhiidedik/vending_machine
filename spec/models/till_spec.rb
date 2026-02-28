# frozen_string_literal: true

require 'ostruct'
require_relative '../spec_helper'
require_relative '../../lib/vending_machine/models/till'

RSpec.describe VendingMachine::Models::Till do
  let(:coin_25) { OpenStruct.new(value: 0.25, quantity: 10) }
  let(:coin_50) { OpenStruct.new(value: 0.50, quantity: 2) }
  let(:coin_100) { OpenStruct.new(value: 1.00, quantity: 1) }
  let(:initial_coins) { [coin_25, coin_50, coin_100] }

  subject(:till) { described_class.new(initial_coins: initial_coins) }

  describe '#initialize' do
    it 'converts float values to integer cents correctly' do
      expect(till.coins.keys).to contain_exactly(25, 50, 100)
    end

    it 'sets correct quantities' do
      expect(till.coins[25]).to eq(10)
      expect(till.coins[50]).to eq(2)
    end
  end

  describe '#acceptable_denomination?' do
    it 'returns true for existing denominations' do
      expect(till.acceptable_denomination?(25)).to be_truthy
    end

    it 'returns false for unknown denominations' do
      expect(till.acceptable_denomination?(10)).to be_falsey
    end
  end

  describe '#calculate_change' do
    it 'returns an empty hash when amount is zero' do
      expect(till.calculate_change(0)).to eq({})
    end

    it 'returns the optimal change using the greedy algorithm' do
      result = till.calculate_change(75)
      expect(result).to eq({ 50 => 1, 25 => 1 })
    end

    it 'uses multiple coins of the same denomination if needed' do
      result = till.calculate_change(50)
      expect(result).to eq({ 50 => 1 })
    end

    it 'returns nil if change cannot be precisely calculated' do
      expect(till.calculate_change(10)).to be_nil
    end

    it 'returns nil if there are not enough coins in the till' do
      expect(till.calculate_change(500)).to be_nil
    end

    context 'when large denominations are empty' do
      let(:coin_empty) { OpenStruct.new(value: 1.00, quantity: 0) }
      let(:initial_coins) { [coin_25, coin_empty] }

      it 'uses smaller coins when large ones are unavailable' do
        # Нужно 50 центов, монеты 1.00 нет, берем две по 25
        expect(till.calculate_change(50)).to eq({ 25 => 2 })
      end
    end
  end

  describe '#add_coins' do
    it 'increments coin quantities' do
      expect { till.add_coins({ 25 => 2, 100 => 1 }) }
        .to change { till.coins[25] }.by(2)
                                     .and change { till.coins[100] }.by(1)
    end
  end

  describe '#dispense_change' do
    it 'decrements coin quantities' do
      expect { till.dispense_change({ 50 => 1, 25 => 2 }) }
        .to change { till.coins[50] }.by(-1)
                                     .and change { till.coins[25] }.by(-2)
    end
  end
end
