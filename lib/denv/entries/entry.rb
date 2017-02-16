class DEnv
  class Entries
    class Entry

      include Comparable

      attr_reader :key, :value, :time
      alias :hash :key

      def initialize(key, value, time = Time.now)
        @key   = key.to_s
        @value = value.to_s
        @time  = time
      end

      def <=>(other)
        key <=> other.key
      end

      def eql?(other)
        key == other.key && value == other.value
      end

    end
  end
end
