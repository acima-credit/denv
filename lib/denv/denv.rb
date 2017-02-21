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

    def reload
      sources.each { |x| x.reload }
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
      level = :debug
      values = [entry.origin, entry.key, entry.value]
      if logger.level >= Logger::INFO
        level = :info
        values[2] = entry.masked_value
      end
      logger.send level, ('DEnv : env! | %-10.10s : %s = %s' % values)
    end

  end
end
