# frozen_string_literal: true

class DEnv
  class Sources
    class Set
      include Enumerable
      extend Forwardable

      def_delegators :@all, :key?, :keys, :values, :clear, :size
      def_delegators :values, :each

      def initialize
        @all = {}
      end

      def add(source)
        return false if key? source.key

        @all[source.key] = source
      end

      alias inspect to_s
    end
  end
end
