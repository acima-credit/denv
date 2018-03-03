# frozen_string_literal: true

class DEnv
  class HashMasker
    def self.mask(hsh, *patterns)
      new(hsh, *patterns).result
    end

    attr_reader :result

    def initialize(hash, *patterns)
      @result = mask_hash hash, regexp_patterns(patterns)
    end

    private

    def regexp_patterns(patterns)
      patterns.map do |pattern|
        pattern.is_a?(Regexp) ? pattern : /#{pattern}/i
      end
    end

    def mask_hash(hash, patterns)
      hash.each_with_object({}) do |(k, v), h|
        ptrn = patterns.find { |x| k =~ x }
        h[k] = ptrn ? self.class.mask_value(v) : v
      end
    end

    def self.mask_value(value, size = value.size)
      case size
      when 0..4
        '*' * size
      when 5..6
        mask = '*' * (value.size - 2)
        value[0, 1] + mask + value[-1, 1]
      else
        mask = '*' * (value.size - 4)
        value[0, 2] + mask + value[-2, 2]
      end
    end
  end
end
