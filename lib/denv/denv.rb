# frozen_string_literal: true

require 'set'
require 'pathname'
require 'logger'

class DEnv
  class << self
    def gem_root
      @gem_root ||= Pathname.new File.expand_path('../../..', __FILE__)
    end

    def sources
      @sources ||= Sources::Set.new
    end

    def clear
      sources.clear
    end

    def results
      Changes::Results.new
    end

    def changes
      results.to_hash
    end

    def safe_changes(*patterns)
      results.to_safe_hash *patterns
    end

    def changes_ary
      results.to_a
    end

    def env!
      results.each do |entry|
        log_env_change entry
        ENV[entry.key] = entry.value
      end
    end

    def append_env!
      results.each do |entry|
        next if ENV.key? entry.key

        log_env_change entry
        ENV[entry.key] = entry.value
      end
    end

    def strip_env!
      ENV.keys.sort.each do |key|
        ENV[key.strip] = ENV.delete(key).strip
      end
    end

    def list_env
      ENV.keys.sort.map { |x| [x, ENV[x]] }
    end

    def print_env
      list = list_env
      max  = list.inject(0) { |t, x| x.first.size > t ? x.first.size : t } + 2
      list.each do |k, v|
        puts format("ENV : %-#{max}.#{max}s : %s", k.inspect, v.inspect)
      end
    end

    def reload
      sources
        .reject { |x| x.type == 'env' }
        .each(&:reload)
    end

    def reload!
      reload
      env!
    end

    def logger
      @logger ||= Logger.new(STDOUT).tap { |x| x.level = Logger::INFO }
    end

    attr_writer :logger

    private

    def add(source)
      sources.add(source)
      self
    end

    def log_env_change(entry)
      level  = :debug
      values = [entry.origin, entry.key, entry.value]
      if logger.level >= Logger::INFO
        level     = :info
        values[2] = entry.masked_value
      end
      logger.send level, format('DEnv : env! | %-10.10s : %s = %s', *values)
    end
  end
end
