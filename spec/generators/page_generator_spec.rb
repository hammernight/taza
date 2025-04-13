require 'spec_helper'

describe Taza::PageGenerator do
  include Helpers::Taza

  before(:each) do
    capture_stdout { Taza::SiteGenerator.new(['foo_site']).site }
  end

  context "taza page home foo_site" do
    context "creates" do

      let(:subject) { Taza::PageGenerator.new(['home', 'foo_site']) }
      let(:output) { capture_stdout { subject.page  }}

      it 'creates a checkout_page.rb' do
        expect(output).to include('lib/sites/foo_site/pages/home_page.rb')
        expect(File.exist?('lib/sites/foo_site/pages/home_page.rb')).to be true
      end
      it 'creates a checkout_page_spec.rb' do
        expect(output).to include('spec/isolation/home_page_spec.rb')
        expect(File.exist?('spec/isolation/home_page_spec.rb')).to be true
      end

      it 'gives message if site does not exist' do
        bar_page = capture_stdout { Taza::PageGenerator.new(['checkout', 'bar_site']).page }
        expect(bar_page).to include("No such site bar_site exists")
      end

      it 'generates a page that can be required' do
        output
        page_spec = 'spec/isolation/home_page_spec.rb'
        expect(system("ruby -c #{page_spec} > #{null_device}")).to be true
      end

      xit "should be able to access the generated page from the site" do
        run_generator('page', [@page_name, @site_class.to_s], generator_sources)
        stub_settings
        stub_browser
        @site_class.new.check_out_page
      end

      xit "should be able to access the generated page for its site" do
        stub_browser
        stub_settings
        new_site_class = generate_site('Pag')
        run_generator('page', [@page_name, @site_class.to_s], generator_sources)
        run_generator('page', [@page_name, new_site_class.to_s], generator_sources)
        new_site_class.new.check_out_page.class.should_not eql(@site_class.new.check_out_page.class)
      end
    end
  end
end
