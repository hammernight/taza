require 'spec_helper'

describe Taza::SiteGenerator do
  context "taza site foo_site" do
    context "creates" do

      let(:subject) { Taza::SiteGenerator.new(['foo_site']) }
      let(:output) { capture_stdout { subject.site } }

      it 'foo_site.rb' do
        expect(output).to include('lib/sites/foo_site.rb')
        expect(File.exist?('lib/sites/foo_site.rb')).to be true
      end

      it 'lib/sites/foo_site' do
        expect(output).to include('lib/sites/foo_site')
        expect(File.directory?('lib/sites/foo_site')).to be true
      end

      it 'lib/sites/foo_site/flows' do
        expect(output).to include("lib/sites/foo_site/flows")
        expect(File.directory?('lib/sites/foo_site/flows')).to be true
      end

      it 'lib/sites/foo_site/pages' do
        expect(output).to include("lib/sites/foo_site/pages")
        expect(File.directory?('lib/sites/foo_site/pages')).to be true
      end

      it 'lib/sites/foo_site/pages/partials' do
        expect(output).to include("lib/sites/foo_site/pages/partials")
        expect(File.directory?('lib/sites/foo_site/pages/partials')).to be true
      end

      it 'config/foo_site.yml' do
        expect(output).to include("config/foo_site.yml")
        expect(File.exist?('config/foo_site.yml')).to be true
      end

      it 'does not overwrite existing site' do
        capture_stdout { Taza::SiteGenerator.new(['foo_site']).site }
        expect(output).to include(*["identical", "exist"])
      end

      it "generates a site that can uses the block given in new" do
        skip 'will have to fix this later'
        @site_class = generate_site(@site_name)
        stub_settings
        stub_browser
        foo = nil
        @site_class.new { |site| foo = site }
        expect(foo).to_not be_nil
        expect(foo).to be_a_kind_of Taza::Site
      end
    end
  end
end
