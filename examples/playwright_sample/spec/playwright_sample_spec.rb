require 'spec_helper'

RSpec.describe 'Playwright + Taza (example)', :integration do
  it 'navigates and finds an element via unified API' do
    session = Taza::Browser.create(driver: :playwright, browser: :chromium, headless: true)
    begin
      url = 'https://rieken-portfolio.netlify.app/'
      session.goto(url)

      el = Taza::Elements.find(session, css: 'body')

      expect(el).to be_a(Taza::Elements::Element)
      expect(el.visible?).to be(true)
    ensure
      session.close
    end
  end
end

