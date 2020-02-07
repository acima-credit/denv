# frozen_string_literal: true

class DEnv
  module ConcurrentReloading
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

  module NotConcurrentReloading
    attr_reader :reloader_task

    def reload_periodically!(*_)
      raise "Could not load 'concurrent-ruby', cannot load ENV periodically!"
    end

    alias stop_reloading_periodically! reload_periodically!
  end
end

begin
  require 'concurrent'

  DEnv.extend DEnv::ConcurrentReloading
rescue LoadError
  puts "ERROR: Could not load 'concurrent-ruby', cannot load ENV periodically! ..."

  DEnv.extend DEnv::NotConcurrentReloading
end
