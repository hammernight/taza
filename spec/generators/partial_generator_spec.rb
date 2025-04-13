require 'spec_helper'

describe Taza::PartialGenerator do

  before(:each) do
    capture_stdout { Taza::SiteGenerator.new(['foo_site']).site }
  end

  context "taza partial navigation foo_site" do
    context "creates" do

      let(:subject) { Taza::PartialGenerator.new(['navigation', 'foo_site']) }
      let(:output) { capture_stdout { subject.partial } }

      it 'a navigation.rb' do
        expect(output).to include('lib/sites/foo_site/pages/partials/navigation.rb')
        expect(File.exist?('lib/sites/foo_site/pages/partials/navigation.rb')).to be true
      end

      it 'message if site does not exist' do
        bar_page = capture_stdout { Taza::PartialGenerator.new(['navigation', 'bar_site']).partial }
        expect(bar_page).to include("No such site bar_site exists")
      end
    end
  end
end
