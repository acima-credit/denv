# frozen_string_literal: true

class DEnv
  class Entries
    class Set
      include Enumerable
      extend Forwardable

      def_delegators :@all, :values, :size, :clear

      def initialize
        @all = {}
      end

      def each
        values.each { |x| yield x }
      end

      def get(key)
        @all[key.to_s]
      end

      alias [] get

      def set(entry)
        return false if entry.invalid?

        found = get entry.key
        return false if found && found.eql?(entry)

        @all[entry.key] = entry
      end

      alias []= set

      def to_hash
        values.each_with_object({}) { |e, h| h[e.key] = e.value }
      end

      def to_safe_hash(*patterns)
        HashMasker.mask to_hash, *patterns
      end

      def to_s
        %(#<#{self.class.name} keys=#{size}>)
      end

      alias inspect to_s
    end
  end
end
