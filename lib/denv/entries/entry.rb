class DEnv
  class Entries
    class Entry

      include Comparable

      attr_reader :key, :value, :time
      alias :hash :key

      def initialize(key, value, time = Time.now)
        @key   = key.to_s.strip
        @value = value.to_s.strip
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

    end
  end
end
