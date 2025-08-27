require 'spec_helper'

RSpec.describe 'Error normalization' do
  def session_with(goto_raises: nil, close_raises: nil)
    raw = Object.new
    goto_proc = if goto_raises
      ->(_url) { raise goto_raises, 'boom timeout here' }
    else
      ->(_url) { }
    end
    close_proc = if close_raises
      -> { raise close_raises, 'stale element during close' }
    else
      -> { }
    end
    Taza::Browser::Session.new(raw, goto_proc: goto_proc, close_proc: close_proc)
  end

  it 'maps Timeout-like errors to Taza::Errors::TimeoutError' do
    class TimeoutErrorExample < StandardError; end
    s = session_with(goto_raises: TimeoutErrorExample)
    expect { s.goto(TEST_URL) }.to raise_error(Taza::Errors::TimeoutError)
  end

  it 'maps NoSuchElement-like errors to Taza::Errors::ElementNotFound' do
    class NoSuchElementError < StandardError; end
    s = session_with(goto_raises: NoSuchElementError)
    expect { s.goto(TEST_URL) }.to raise_error(Taza::Errors::ElementNotFound)
  end

  it 'maps message-based element not found to Taza::Errors::ElementNotFound' do
    ex = Class.new(StandardError)
    raw = Object.new
    s = Taza::Browser::Session.new(raw,
      goto_proc: ->(_){ raise ex, 'No such element: #foo' },
      close_proc: ->{})
    expect { s.goto(TEST_URL) }.to raise_error(Taza::Errors::ElementNotFound)
  end

  it 'maps StaleElement-like errors to Taza::Errors::StaleElement' do
    class StaleElementReferenceError < StandardError; end
    s = session_with(goto_raises: StaleElementReferenceError)
    expect { s.goto(TEST_URL) }.to raise_error(Taza::Errors::StaleElement)
  end

  it 'maps UnhandledAlert-like errors to Taza::Errors::DialogError' do
    class UnhandledAlertError < StandardError; end
    s = session_with(goto_raises: UnhandledAlertError)
    expect { s.goto(TEST_URL) }.to raise_error(Taza::Errors::DialogError)
  end

  it 'defaults to NavigationError for unknown exceptions' do
    class WeirdDriverError < StandardError; end
    raw = Object.new
    s = Taza::Browser::Session.new(raw,
      goto_proc: ->(_){ raise WeirdDriverError, 'weird unknown error' },
      close_proc: ->{})
    expect { s.goto(TEST_URL) }.to raise_error(Taza::Errors::NavigationError)
  end

  it 'normalizes errors raised during close' do
    class TimeoutDuringClose < StandardError; end
    s = session_with(close_raises: TimeoutDuringClose)
    expect { s.close }.to raise_error(Taza::Errors::TimeoutError)
  end
end
