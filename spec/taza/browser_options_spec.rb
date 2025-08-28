require 'spec_helper'

describe 'Browser.create option coercion and validation' do
  before do
    Taza::Browser.reset_registry!
  end

  after do
    Taza::Browser.reset_registry!
  end

  it 'raises when driver is missing' do
    expect {
      Taza::Browser.create(browser: :firefox)
    }.to raise_error(ArgumentError, /driver is required/i)
  end

  it 'accepts string driver by symbolizing' do
    called = nil
    Taza::Browser.register(:fake) do |params|
      called = params
      Taza::Browser::Session.new(Object.new, goto_proc: ->(_){}, close_proc: ->{})
    end
    session = Taza::Browser.create(driver: 'fake', browser: :foo)
    expect(session).to be_a(Taza::Browser::Session)
    expect(called[:driver]).to eql(:fake)
  end

  it 'coerces headless truthy string values to true' do
    truthy = ['true', 'TRUE', '1', 'yes', 'Yes', 'y', 'Y', " \t TrUe "]
    truthy.each do |val|
      called = nil
      Taza::Browser.reset_registry!
      Taza::Browser.register(:fake) do |params|
        called = params
        Taza::Browser::Session.new(Object.new, goto_proc: ->(_){}, close_proc: ->{})
      end
      Taza::Browser.create(driver: :fake, browser: :foo, headless: val)
      expect(called[:headless]).to eql(true)
    end
  end

  it 'coerces headless falsy string values to false' do
    falsy = ['false', 'FALSE', '0', 'no', 'No', 'n', 'N', " \t FaLsE "]
    falsy.each do |val|
      called = nil
      Taza::Browser.reset_registry!
      Taza::Browser.register(:fake) do |params|
        called = params
        Taza::Browser::Session.new(Object.new, goto_proc: ->(_){}, close_proc: ->{})
      end
      Taza::Browser.create(driver: :fake, browser: :foo, headless: val)
      expect(called[:headless]).to eql(false)
    end
  end

  it 'raises when headless is not boolean-like' do
    expect {
      Taza::Browser.create(driver: :fake, browser: :foo, headless: 'maybe')
    }.to raise_error(ArgumentError, /headless must be a boolean/i)
  end
end
