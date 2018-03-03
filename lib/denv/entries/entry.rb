# frozen_string_literal: true

class DEnv
  class Entries
    class Entry
      include Comparable

      attr_reader :key, :value, :time
      alias hash key

      def initialize(key, value, time = Time.now)
        @key   = clean_key key
        @value = clean_value value
        @time  = time
      end

      def <=>(other)
        key <=> other.key
      end

      def eql?(other)
        key == other.key && value == other.value
      end

      def valid?
        !invalid?
      end

      def invalid?
        key.empty? || key[0, 1] == '#'
      end

      private

      # remove empty ends
      def clean_str(str)
        str.to_s.strip
      end

      def clean_key(key)
        clean_str key
      end

      # unquote, expand newlines, unescape characters
      def clean_value(value)
        clean_str(value)
          .sub(/\A(['"])(.*)\1\z/, '\2')
          .gsub('\n', "\n").gsub('\r', "\r")
          .gsub(/\\([^$])/, '\1')
      end
    end
  end
end
