require 'spec_helper'

describe Taza::FlowGenerator do

  before(:each) do
    capture(:stdout) { Taza::SiteGenerator.new(['foo_site']).site }
  end

  context "taza flow checkout foo_site" do
    context "creates" do

      let(:subject) { Taza::FlowGenerator.new(['checkout', 'foo_site']) }
      let(:output) { capture(:stdout) { subject.flow } }

      it 'a checkout.rb' do
        expect(output).to include('lib/sites/foo_site/flows/checkout.rb')
        expect(File.exists?('lib/sites/foo_site/flows/checkout.rb')).to be true
      end

      it 'a message if site does not exist' do
        bar_page = capture(:stdout) { Taza::FlowGenerator.new(['checkout', 'bar_site']).flow }
        expect(bar_page).to include("No such site bar_site exists")
      end
    end
  end
end
