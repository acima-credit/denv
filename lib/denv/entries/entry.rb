class DEnv
  class Entries
    class Entry

      include Comparable

      attr_reader :key, :value, :time
      alias :hash :key

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
        key.empty? || key[0,1] == '#'
      end

      private

      def clean_key(key)
        key.to_s.strip
      end

      def clean_value(value)
        str = value.to_s.strip

        case str[0,1]
          when "'", '"', '`'
            str[0] = ''
        end

        case str[-1,1]
          when "'", '"', '`'
            str[-1] = ''
        end

        str
      end

    end
  end
end
