class DEnv
  class Sources
    class Base

      include Enumerable
      extend Forwardable

      def_delegators :entries, :values, :clear, :to_hash
      def_delegators :values, :each

      attr_reader :entries

      def initialize
        @entries = Entries::Set.new
        set_entries
      end

      def set_entries
        # Nothing to do here
      end

      def reload
        clear
        set_entries
      end

      private

      def add(key, value, time = Time.now)
        entries.set Entries::Entry.new(key, value, time)
      end

    end
  end
end
