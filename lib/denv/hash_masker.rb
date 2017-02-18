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
        h[k] = ptrn ? mask_value(v) : v
      end
    end

    def mask_value(value)
      case value.size
        when 0
          value
        when 1..4
          mask_string value, value.size
        when 5..10
          mask_string value, 2
        when 11..30
          mask_string value, 3
        else
          mask_string value, value.size / 10
      end
    end

    def mask_string(value, size)
      str              = value.dup.to_s
      str[0, size]     = '*' * size
      str[-size, size] = '*' * size
      str
    end

  end
end