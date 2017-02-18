class DEnv
  class Sources
    class File < Base

      attr_reader :filename, :path

      def initialize(filename, root = nil, _caller = caller)
        @filename = filename
        root      ||= get_root_from_caller _caller
        @path     = Pathname.new(root).join filename
        super()
      end

      def type
        'file'
      end

      def key
        "#{type[0,1]}:#{::File.basename(filename)}"
      end

      private

      def set_entries
        unless path.exist?
          DEnv.logger.error 'DEnv : source  : %-15.15s | %s' % [key, "could not find #{path}"]
          return false
        end

        DEnv.logger.debug 'DEnv : source  : %-15.15s | %s' % [key, "found #{path}"]
        lines.each do |line|
          k, v = line.split '='
          add k, v
        end
      end

      def lines
        body.gsub('\n', "\n").gsub('\r', "\r").split(/[\n\r]+/)
      end

      def body
        ::File.open(path, 'rb:bom|utf-8') { |f| f.read }
      end

      def get_root_from_caller(_caller)
        base = _caller.first.split(':').first
        ::File.dirname ::File.expand_path(base)
      end

    end
  end

  def self.from_file(filename, root = nil, _caller = caller)
    from_env
    add Sources::File.new(filename, root, _caller)
  end

  def self.from_file!(filename, root = nil, _caller = caller)
    from_file filename, root, _caller
    env!
  end

end
