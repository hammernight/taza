require 'spec_helper'

describe 'Adapter plugin discovery' do
  before do
    Taza::Browser.reset_registry!
    Taza::Browser.instance_variable_set(:@plugins_loaded, false)
  end

  after do
    ENV.delete('TAZA_AUTOLOAD_DRIVERS')
    Taza::Browser.instance_variable_set(:@plugins_loaded, false)
  end

  it 'does not autoload plugins when TAZA_AUTOLOAD_DRIVERS is not set' do
    Taza::Browser.expects(:load_plugins!).never
    expect {
      Taza::Browser.create(driver: :nonexistent_driver, browser: :foo)
    }.to raise_error(StandardError, /Unknown driver/)
  end

  it 'autoloads plugins once when TAZA_AUTOLOAD_DRIVERS=1' do
    ENV['TAZA_AUTOLOAD_DRIVERS'] = '1'

    fake_paths = [
      '/fake/gem1/lib/taza/drivers/alpha.rb',
      '/fake/gem2/lib/taza/drivers/beta.rb'
    ]
    Gem.stubs(:find_files).with('taza/drivers/*.rb').returns(fake_paths)

    # Allow rubygems bootstrap require, assert plugin requires
    Kernel.stubs(:require).with('rubygems').returns(true)
    fake_paths.each { |p| Kernel.expects(:require).with(p).returns(true) }

    expect {
      Taza::Browser.create(driver: :still_unknown, browser: :foo)
    }.to raise_error(StandardError, /Unknown driver/)
  end
end
