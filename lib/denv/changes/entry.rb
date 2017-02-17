class DEnv
  class Changes
    class Entry

      attr_reader :key, :value, :origin

      def initialize(key, value, origin)
        @key    = key
        @value  = value
        @origin = origin
      end

      def to_a
        [key, value, origin]
      end

      def to_s
        "[CE:#{key}:#{value}:#{origin}]"
      end

      alias :inspect :to_s

    end
  end
end