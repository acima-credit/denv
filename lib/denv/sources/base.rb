class DEnv
  class Sources
    class Base

      include Enumerable
      extend Forwardable

      def_delegators :entries, :values, :clear, :to_hash, :to_safe_hash
      def_delegators :values, :each

      def initialize
        # @entries = Entries::Set.new
        # set_entries
      end

      def entries
        return @entries unless @entries.nil?

        @entries = Entries::Set.new
        set_entries
        @entries
      end

      def set_entries
        # Nothing to do here
      end

      def reload
        clear
        set_entries
      end

      private

      def add(k, v, time = Time.now)
        entry = Entries::Entry.new(k, v, time)
        ary   = [key, (entry.valid? ? 'add' : 'skip'), entry.key, entry.value]
        DEnv.logger.debug 'DEnv : source  : %-15.15s | %-4.4s : %-15.15s : %s' % ary
        entries.set entry if entry.valid?
      end

    end
  end
end
