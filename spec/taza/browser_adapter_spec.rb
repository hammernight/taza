require 'spec_helper'

describe 'Browser adapter registry' do
  before do
    # Ensure clean state for custom driver name
    @driver_name = :fake_driver
  end

  it 'uses a registered provider to create a Session' do
    raw = mock('raw-driver')
    called = { goto: nil, close: 0 }

    Taza::Browser.register(@driver_name) do |params|
      expect(params[:browser]).to eql(:foo)
      Taza::Browser::Session.new(
        raw,
        goto_proc: ->(url) { called[:goto] = url },
        close_proc: -> { called[:close] += 1 }
      )
    end

    session = Taza::Browser.create(driver: @driver_name, browser: :foo)
    expect(session).to be_a(Taza::Browser::Session)

    session.goto(TEST_URL)
    expect(called[:goto]).to eql(TEST_URL)

    session.close
    expect(called[:close]).to eql(1)
  end

  it 'forwards unknown methods to the raw driver' do
    raw = mock('raw-driver')
    raw.expects(:title).returns('Hello')

    session = Taza::Browser::Session.new(
      raw,
      goto_proc: ->(url) { },
      close_proc: -> { }
    )

    expect(session.title).to eql('Hello')
    expect(session.respond_to?(:title)).to eql(true)
  end
end
