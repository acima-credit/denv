class DEnv
  class Changes
    class Results

      extend Forwardable

      def_delegators :values, :to_hash, :to_safe_hash, :to_a

      attr_reader :values

      def initialize
        set_originals
        set_changes
      end

      def self.to_hash
        new.to_hash
      end

      private

      def set_originals
        @originals = DEnv.sources.first { |x| x.type == 'env' }.to_hash
      end

      def set_changes
        @values = Set.new

        DEnv.sources.each do |source|
          source.to_hash.each do |k, v|
            entry = Entry.new k, v, source.key
            found = original_present?(entry)
            ary   = [entry.origin, (found ? 'skip' : 'add'), entry.key, entry.value]
            DEnv.logger.debug 'DEnv : changes : %-15.15s | %-4.4s : %-15.15s : %s' % ary
            values.set entry unless found
          end
        end
      end

      def original_present?(entry)
        value = @originals[entry.key]
        value && entry.value == value
      end

    end
  end
end