# frozen_string_literal: true

class DEnv
  class Sources
    class Set
      include Enumerable
      extend Forwardable

      attr_reader :keys

      def_delegators :@all, :values, :size

      def initialize
        clear
      end

      def add(source)
        @all[source.key] = source
        @keys << source.key
      end

      def key?(key)
        @keys.include? key
      end

      def each
        @keys.each { |k| yield @all[k] }
      end

      def clear
        @all = {}
        @keys = []
      end

      alias inspect to_s
    end
  end
end
