# frozen_string_literal: true

# frozen_string_literal=true

class DEnv
  class Sources
    class SecretsDir < Base
      def initialize(dirname, root = nil, callr = caller)
        @dirname = dirname
        root ||= Base.get_root_from_caller callr
        @path = Pathname.new(root).join(dirname)

        raise "Error accessing secret env dir at #{@path}" unless root_accessible?

        super()
      end

      def type
        'secrets_dir'
      end

      def key
        "#{type[0, 1]}:#{::File.basename(@path)}"
      end

      private

      def secrets_files
        Dir.children(@path)
      end

      def set_entries
        unless @path.exist?
          DEnv.logger.error format('DEnv : source  : %-15.15s | %s', key, "could not find #{@path}")
          return false
        end

        DEnv.logger.debug format('DEnv : source  : %-15.15s | %s', key, "found #{@path}")
        secrets_files.each do |secret_name|
          process_file_secret(secret_name)
        end
      end

      def process_file_secret(secret_name)
        secret_path = @path.join(secret_name)
        raise "Secret file #{secret_path} is not accessible" unless ::File.readable?(secret_path)

        secret_file = ::File.open(secret_path)
        add secret_name, secret_file.read, secret_file.stat.mtime
      end

      def root_accessible?
        ::File.exist?(@path) && ::File.readable?(@path) && ::File.executable?(@path)
      end
    end
  end

  def self.from_secrets_dir(dirname, root = nil, _callr = caller)
    add Sources::SecretsDir.new(dirname, root)
  end

  def self.from_secrets_dir!(dirname, root = nil, _callr = caller)
    from_secrets_dir dirname, root
    env!
  end
end
