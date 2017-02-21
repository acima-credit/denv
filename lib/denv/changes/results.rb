class DEnv
  class Changes
    class Results

      extend Forwardable

      def_delegators :values, :each, :to_hash, :to_safe_hash, :to_a

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
        @originals = ENV.to_hash
      end

      def set_changes
        @values = Set.new

        DEnv.sources.each do |source|
          next if source.type == 'env'
          source.each { |entry| process_entry source, entry.key, entry.value }
        end
      end

      def process_entry(source, k, v)
        entry  = Entry.new k, v, source.key
        do_add = add? entry
        debug_entry entry, do_add
        values.set entry if do_add
      end

      def debug_entry(entry, do_add)
        ary = [entry.origin, (do_add ? 'add' : 'skip'), entry.key, entry.value]
        DEnv.logger.debug 'DEnv : changes : %-15.15s | %-4.4s : %-15.15s : %s' % ary
      end

      def add?(entry)
        missing?(entry) || different_original?(entry) || value_present?(entry)
      end

      def missing?(entry)
        !@originals.key?(entry.key)
      end

      def different_original?(entry)
        entry.value != @originals[entry.key]
      end

      def value_present?(entry)
        values.key?(entry.key)
      end

    end
  end
end