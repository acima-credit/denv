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

    def changes_ary
      results.to_a
    end

    def env!
      changes.each do |k, v|
        logger.debug 'DEnv : env!                      |      : %-15.15s : %s' % [k, v]
        ENV[k] = v
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

  end
end
