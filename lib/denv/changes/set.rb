# frozen_string_literal: true

class DEnv
  class Changes
    class Set < ::SimpleDelegator
      def initialize
        super []
      end

      def values
        __getobj__
      end

      def key?(key)
        values.any? { |x| x.key == key.to_s }
      end

      def set(entry)
        key?(entry.key) ? replace(entry) : add(entry)
      end

      def clear_from_env
        values.delete_if { |entry| ENV.key?(entry.key) && entry.value == ENV[entry.key] }
      end

      def to_hash
        each_with_object({}) { |entry, hsh| hsh[entry.key] = entry.value }
      end

      def to_safe_hash(*patterns)
        HashMasker.mask to_hash, *patterns
      end

      def to_a
        each_with_object([]) { |entry, ary| ary << entry.to_a }
      end

      def to_s
        %(#<DEnv::Changes::Set keys=#{size}>)
      end

      alias inspect to_s

      private

      def replace(entry)
        values.each_with_index { |e, i| values[i] = entry if entry.key == e.key }
      end

      def add(entry)
        values << entry
      end
    end
  end
end
