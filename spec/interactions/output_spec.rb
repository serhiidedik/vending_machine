# frozen_string_literal: true

require 'stringio'
require 'ostruct'

require 'spec_helper'

RSpec.describe VendingMachine::Interactions::Output do
  let(:io) { StringIO.new }
  let(:inventory) { instance_double(VendingMachine::Models::Inventory) }
  let(:texts) do
    OpenStruct.new(
      welcome_message: 'WELCOME',
      header: { col: OpenStruct.new(name: 'Name') },
      instructions: { help: 'Press H' },
      messages: OpenStruct.new(
        balance: 'Balance',
        selected: 'Selected',
        change: 'Change:',
        success: 'OK',
        done: 'Finished',
        exit: 'Bye'
      )
    )
  end

  subject(:output) { described_class.new(inventory: inventory, texts: texts, io: io) }

  describe '#render_delimiter' do
    it 'prints a line of symbols with correct width' do
      output.render_delimiter(symbol: '=')
      expect(io.string).to eq("#{'=' * 100}\n")
    end
  end

  describe '#render_balance' do
    it 'formats money and prints balance message' do
      output.render_balance(cents: 150)
      expect(io.string).to eq("Balance: $1.50\n")
    end
  end

  describe '#render_current_state' do
    let(:product) { instance_double(VendingMachine::Models::Product, name: 'Cola', price_cents: 100) }

    it 'renders balance, selection and prompt' do
      output.render_current_state(100, product)
      expect(io.string).to include('Balance: $1.00')
      expect(io.string).to include('Selected: Cola ($1.00)')
      expect(io.string).to include('> ')
    end

    it 'does not render balance if it is zero' do
      output.render_current_state(0, product)
      expect(io.string).not_to include('Balance')
    end
  end

  describe '#render_operation_status' do
    context 'with success result' do
      let(:result) { { status: :success, message: :done, data: 50 } }

      it 'formats and prints a complex status message' do
        output.render_operation_status(result: result)
        expect(io.string).to eq("OK Finished $0.50\n")
      end
    end

    context 'with product and change data' do
      let(:product) { instance_double(VendingMachine::Models::Product, name: 'Tea', price_cents: 50) }
      let(:result) do
        {
          status: :success,
          message: :done,
          data: { product: product, change: { 25 => 1 } }
        }
      end

      it 'renders product info and list of coins' do
        output.render_operation_status(result: result)
        expect(io.string).to include('Tea ($0.50)')
        expect(io.string).to include('Change: $0.25')
      end
    end
  end

  describe '#render_menu' do
    before do
      product = instance_double(VendingMachine::Models::Product, name: 'Juice', price_cents: 200)
      allow(inventory).to receive(:products).and_return({ product => 5 })
      allow(inventory).to receive(:quantity_of).with('Juice').and_return(5)
    end

    it 'renders table header and product rows' do
      output.render_menu
      expect(io.string).to include('Name')
      expect(io.string).to include('Juice')
      expect(io.string).to include('$2.00')
    end
  end
end
