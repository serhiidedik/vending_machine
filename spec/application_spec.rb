# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VendingMachine::Application do
  let(:output) { instance_double(VendingMachine::Interactions::Output) }
  let(:composer) { instance_double(VendingMachine::Interactions::Composer) }
  let(:till) { instance_double(VendingMachine::Models::Till) }

  before do
    allow_any_instance_of(described_class).to receive(:load_configs)
    allow_any_instance_of(described_class).to receive(:load_dependencies)

    allow_any_instance_of(described_class).to receive(:output).and_return(output)
    allow_any_instance_of(described_class).to receive(:composer).and_return(composer)
    allow_any_instance_of(described_class).to receive(:till).and_return(till)

    allow(output).to receive(:render_welcome_block)
    allow(output).to receive(:render_current_state)
    allow(output).to receive(:render_exit)
    allow(output).to receive(:render_operation_status)
    allow(output).to receive(:render_help)
    allow(output).to receive(:render_menu)
    allow(output).to receive(:render_till_coins)

    allow(composer).to receive(:current_balance).and_return(0)
    allow(composer).to receive(:selected_product).and_return(nil)
  end

  describe '#initialize' do
    it 'renders the welcome block on startup' do
      expect(output).to receive(:render_welcome_block)
      described_class.new
    end
  end

  describe '#run' do
    subject(:app) { described_class.new }

    it 'terminates the loop when a quit command is entered' do
      allow(app).to receive(:gets).and_return("exit\n")

      app.run
      expect(output).to have_received(:render_exit)
    end

    it 'handles Interrupt (Ctrl+C) gracefully' do
      allow(app).to receive(:process_command).and_raise(Interrupt)

      app.run
      expect(output).to have_received(:render_exit)
    end
  end

  describe 'command routing' do
    subject(:app) { described_class.new }

    def mock_input(*commands)
      allow(app).to receive(:gets).and_return(*(commands.map { |c| "#{c}\n" } << "q\n"))
    end

    it 'routes "buy" command to composer' do
      mock_input('buy')
      expect(composer).to receive(:buy)
      app.run
    end

    it 'routes numeric input to composer as a coin' do
      mock_input('0.50')
      expect(composer).to receive(:add_coin).with('0.50')
      app.run
    end

    it 'routes "till" command to output with coins' do
      mock_input('till')
      allow(till).to receive(:coins).and_return({ 100 => 10 })
      expect(output).to receive(:render_till_coins).with(coins: { 100 => 10 })
      app.run
    end

    it 'routes unknown input to product selection' do
      mock_input('unknown_item')
      expect(composer).to receive(:select_product).with('unknown_item')
      app.run
    end
  end
end
