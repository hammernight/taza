require 'spec_helper'

describe Taza::ProjectGenerator do
  context "taza create foo_site" do
    context "creates" do

      let(:subject) { Taza::ProjectGenerator.new(['foo_site']) }
      let(:output) { capture(:stdout) { subject.create } }

      it 'a Gemfile' do
        expect(output).to include("Gemfile")
        expect(File.exists?('Gemfile')).to be true
      end

      it 'a Rakefile' do
        expect(output).to include('Rakefile')
        expect(File.exists?('Rakefile')).to be true
      end

      it 'the Rakefile can be required' do
        output
        expect(system("ruby -c Rakefile > #{null_device}")).to be true
      end

      it 'config/config.yml' do
        expect(output).to include('config/config.yml')
        expect(File.exists?('config/config.yml')).to be true
      end

      it 'lib/sites' do
        expect(output).to include('lib/sites')
        expect(File.directory?('lib/sites')).to be true
      end

      it 'a spec_helper.rb' do
        expect(output).to include('spec/spec_helper.rb')
        expect(File.exists?('spec/spec_helper.rb')).to be true
      end

      it 'spec_helper.rb can be required' do
        output
        expect(system("ruby -c spec/spec_helper.rb > #{null_device}")).to be true
      end

      it 'spec/isolation' do
        expect(output).to include('spec/isolation')
        expect(File.directory?('spec/isolation')).to be true
      end

      it 'spec/integration' do
        expect(output).to include('spec/integration')
        expect(File.directory?('spec/integration')).to be true
      end

      it 'bin' do
        expect(output).to include('bin')
        expect(File.directory?('bin')).to be true
      end

      it 'the taza executable' do
        expect(output).to include('spec/spec_helper.rb')
        expect(File.exists?('spec/spec_helper.rb')).to be true
      end

      xit "should generate a console script" do
        run_generator('taza', [APP_ROOT], generator_sources)
        expect(File.exists?(File.join(APP_ROOT, 'script', 'console'))).to be true
      end

      xit "should generate a windows console script" do
        run_generator('taza', [APP_ROOT], generator_sources)
        expect(File.exists?(File.join(APP_ROOT, 'script', 'console.cmd'))).to be true
      end
    end
  end
end
