module Taza
  module Events
    @subscribers = Hash.new { |h, k| h[k] = [] }

    class << self
      def subscribe(event, listener = nil, &block)
        cb = listener || block
        raise ArgumentError, 'listener or block required' unless cb
        @subscribers[event.to_sym] << cb
        cb
      end

      def unsubscribe(event, cb)
        @subscribers[event.to_sym].delete(cb)
      end

      def publish(event, payload = nil)
        @subscribers[event.to_sym].each do |cb|
          begin
            cb.call(payload)
          rescue => _e
            # swallow to avoid breaking caller; consider logging
          end
        end
      end

      def subscribers(event)
        @subscribers[event.to_sym].dup
      end
    end
  end
end

