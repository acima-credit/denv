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
          source.each { |entry| set_entry(source, entry) }
        end
        @values.clear_from_env
      end

      def set_entry(source, entry)
        values.set Entry.new(entry.key, entry.value, source.key)
      end

    end
  end
end