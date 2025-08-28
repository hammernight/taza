require 'spec_helper'

describe Taza::Events do
  it 'allows subscribe, publish and unsubscribe' do
    received = []
    cb = Taza::Events.subscribe(:test_event) { |payload| received << payload }

    Taza::Events.publish(:test_event, { a: 1 })
    expect(received).to eql([{ a: 1 }])

    Taza::Events.unsubscribe(:test_event, cb)
    Taza::Events.publish(:test_event, { a: 2 })
    expect(received).to eql([{ a: 1 }])
  end
end

