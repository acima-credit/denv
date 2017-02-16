class DEnv
  class Sources
    class Env < Base

      def type
        'env'
      end

      def key
        type
      end

      private

      def set_entries
        ::ENV.each { |k, v| add k, v }
      end

    end
  end

  def self.from_env
    add Sources::Env.new
  end

end
