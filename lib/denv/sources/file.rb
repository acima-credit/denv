# frozen_string_literal: true

class DEnv
  class Sources
    class File < Base
      attr_reader :filename, :path

      def initialize(filename, root = nil, callr = caller)
        @filename = filename
        root ||= Base.get_root_from_caller callr
        @path = Pathname.new(root).join filename
        super()
      end

      def type
        'file'
      end

      def key
        "#{type[0, 1]}:#{::File.basename(filename)}"
      end

      private

      def set_entries
        unless path.exist?
          DEnv.logger.error format('DEnv : source  : %-15.15s | %s', key, "could not find #{path}")
          return false
        end

        DEnv.logger.debug format('DEnv : source  : %-15.15s | %s', key, "found #{path}")
        lines.each do |line|
          k, v = line.split '=', 2
          add k, v
        end
      end

      def lines
        body.gsub('\n', "\n").gsub('\r', "\r").split(/[\n\r]+/)
      end

      def body
        ::File.open(path, 'rb:bom|utf-8', &:read)
      end
    end
  end

  def self.from_file(filename, root = nil, callr = caller)
    add Sources::File.new(filename, root, callr)
  end

  def self.from_file!(filename, root = nil, callr = caller)
    from_file filename, root, callr
    env!
  end
end
