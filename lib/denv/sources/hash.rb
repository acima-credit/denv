# frozen_string_literal: true

class DEnv
  class Sources
    class Hash < Base
      def initialize(hash)
        @hash = hash
        raise StandardError, "Error - expecting a hash parameter" unless hash.is_a?(::Hash)

        super()
      end

      def type
        'hash'
      end

      def key
        "#{type[0, 1]}:#{@hash.object_id}"
      end

      private

      def set_entries
        @hash.each do |key, value|
          add(key, value)
        end
      end
    end
  end

  def self.from_hash(hash)
    add(Sources::Hash.new(hash))
  end

  def self.from_hash!(hash)
    from_hash(hash)
    env!
  end
end
