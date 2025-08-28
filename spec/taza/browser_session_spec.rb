require 'spec_helper'

describe Taza::Browser::Session do
  it 'publishes before_navigate and after_navigate events on goto' do
    received = []
    sub1 = Taza::Events.subscribe(:before_navigate) { |p| received << [:before, p[:url]] }
    sub2 = Taza::Events.subscribe(:after_navigate) { |p| received << [:after, p[:url]] }

    begin
      raw = Object.new
      session = Taza::Browser::Session.new(
        raw,
        goto_proc: ->(url) { @navigated = url },
        close_proc: -> { }
      )
      session.goto(TEST_URL)
      expect(received).to eql([[:before, TEST_URL], [:after, TEST_URL]])
    ensure
      Taza::Events.unsubscribe(:before_navigate, sub1)
      Taza::Events.unsubscribe(:after_navigate, sub2)
    end
  end

  it 'publishes session_closed on close' do
    received = []
    sub = Taza::Events.subscribe(:session_closed) { |p| received << :closed }

    begin
      raw = Object.new
      session = Taza::Browser::Session.new(
        raw,
        goto_proc: ->(url) { },
        close_proc: -> { }
      )
      session.close
      expect(received).to eql([:closed])
    ensure
      Taza::Events.unsubscribe(:session_closed, sub)
    end
  end
end
