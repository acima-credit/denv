# frozen_string_literal: true

begin
  require 'concurrent'

  class DEnv
    class << self
      attr_reader :reloader_task

      def reload_periodically!(interval = 30, timeout = 5)
        return false unless @reloader_task.nil?

        options        = { execution_interval: interval, timeout_interval: timeout }
        @reloader_task = ::Concurrent::TimerTask.new(options) { DEnv.reload! }
        @reloader_task.execute
        true
      end

      def stop_reloading_periodically!
        return false if @reloader_task.nil?

        @reloader_task.shutdown
        @reloader_task = nil
        true
      end
    end
  end
rescue LoadError
  puts "ERROR: Could not load 'concurrent-ruby', cannot load ENV periodically! ..."

  class DEnv
    class << self
      attr_reader :reloader_task

      def reload_periodically!(*_)
        raise "Could not load 'concurrent-ruby', cannot load ENV periodically!"
      end

      def stop_reloading_periodically!
        raise "Could not load 'concurrent-ruby', cannot load ENV periodically!"
      end
    end
  end
end
