module Taza
  module Errors
    class NavigationError < StandardError; end
    class TimeoutError < StandardError; end
    class ElementNotFound < StandardError; end
    class StaleElement < StandardError; end
    class DialogError < StandardError; end
  end
end

