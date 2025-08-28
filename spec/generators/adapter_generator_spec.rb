require 'spec_helper'

describe Taza::AdapterGenerator do
  context 'taza adapter acme' do
    let(:subject) { Taza::AdapterGenerator.new(['acme']) }

    it 'creates the adapter driver file' do
      output = capture_stdout { subject.adapter }
      expect(output).to include('lib/taza/drivers/acme.rb')
      expect(File.exist?('lib/taza/drivers/acme.rb')).to be true
    end

    it 'creates the adapter spec' do
      capture_stdout { subject.adapter }
      expect(File.exist?('spec/taza/acme_adapter_spec.rb')).to be true
    end

    it 'creates the shared adapter contract if missing' do
      capture_stdout { subject.adapter }
      expect(File.exist?('spec/support/shared_adapter_contract.rb')).to be true
    end
  end
end

