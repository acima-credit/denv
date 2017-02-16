class DEnv
  class ChangeSet < Entries::Set

    def initialize
      super()
      set_entries
    end

    private

    def set_entries
      DEnv.sources.each do |source|
        source.values.each { |entry| set entry }
      end
    end

    def set(entry)
      value = ENV.fetch entry.key, ''
      super unless entry.value == value
    end

  end
end