require 'spec_helper'

RSpec.describe 'Custom adapter (acme) + unified elements', :integration do
  it 'creates a session, navigates, and uses unified element API' do
    session = Taza::Browser.create(driver: :acme)
    expect(session).to be_a(Taza::Browser::Session)

    # Goto should not raise
    session.goto('http://example.invalid')

    el = Taza::Elements.find(session, css: '#anything')
    expect(el).to be_a(Taza::Elements::Element)
    expect(el.visible?).to be(true)

    # Exercise a couple of wrapper calls
    el.click
    el.fill('value')
  end
end

