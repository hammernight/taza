require 'spec_helper'

RSpec.describe 'Unified element API' do
  it 'finds elements via Watir using raw.element with locator hash' do
    raw = mock('watir-browser')
    found = mock('watir-element')
    locator = { css: '#foo' }
    raw.expects(:element).with(css: '#foo').returns(found)

    session = Taza::Browser::Session.new(raw, goto_proc: ->(_){}, close_proc: ->{})
    el = Taza::Elements.find(session, locator)
    expect(el).to be_a(Taza::Elements::Element)
    expect(el.raw).to eql(found)
  end

  it 'finds elements via Selenium using find_element(by, value)' do
    raw = mock('selenium-driver')
    element = mock('selenium-element')
    raw.expects(:find_element).with(:id, 'foo').returns(element)

    session = Taza::Browser::Session.new(raw, goto_proc: ->(_){}, close_proc: ->{})
    el = Taza::Elements.find(session, id: 'foo')
    expect(el.raw).to eql(element)
  end

  it 'finds elements via Playwright using locator() with mapped selector' do
    raw = mock('playwright-page')
    element = mock('playwright-locator')
    raw.expects(:locator).with("xpath=//div[@id='x']").returns(element)

    session = Taza::Browser::Session.new(raw, goto_proc: ->(_){}, close_proc: ->{})
    el = Taza::Elements.find(session, xpath: "//div[@id='x']")
    expect(el.raw).to eql(element)
  end

  it 'Page DSL supports locator sugar and returns a unified Element' do
    klass = Class.new(Taza::Page) do
      element(:foo, css: '#foo')
    end

    # Provide a fake raw that supports .element (Watir path)
    raw = mock('raw')
    watir_el = mock('watir-element')
    raw.expects(:element).with(css: '#foo').returns(watir_el)

    session = Taza::Browser::Session.new(raw, goto_proc: ->(_){}, close_proc: ->{})
    page = klass.new
    page.browser = session

    el = page.foo
    expect(el).to be_a(Taza::Elements::Element)
    expect(el.raw).to eql(watir_el)
  end
end
