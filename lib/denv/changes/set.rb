class DEnv
  class Changes
    class Set < SimpleDelegator

      def initialize
        super []
      end

      def values
        __getobj__
      end

      def set(entry)
        values << entry
      end

      def to_hash
        each_with_object({}) { |entry, hsh| hsh[entry.key] = entry.value }
      end

      def to_a
        each_with_object([]) { |entry, ary| ary << entry.to_a }
      end

      def to_s
        %{#<DEnv::Changes::Set keys=#{size}>}
      end

      alias :inspect :to_s

    end
  end
end
