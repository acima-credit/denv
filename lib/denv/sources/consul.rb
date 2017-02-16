require 'net/http'
require 'uri'
require 'multi_json'
require 'base64'
require 'yaml'

class DEnv
  class Sources
    class Consul < Base

      attr_reader :url, :path, :options

      def initialize(url, path, options = {})
        @url     = url
        @path    = path
        @options = options
        super()
      end

      def type
        'consul'
      end

      def key
        "#{type}:#{uri.host}:#{path}"
      end

      private

      def set_entries
        json_response.each do |entry|
          next unless entry['Value']

          k = entry['Key'].gsub(path, '')
          v = Base64.decode64 entry['Value'].to_s
          add k, v
        end
      end

      def json_response
        response = get_response
        return [] unless response.code.to_i == 200

        MultiJson.load response.body
      rescue Exception => e
        DEnv.logger.error "Exception: #{e.class.name} : #{e.message}\n  #{e.backtrace[0, 5].join("\n  ")}"
        return []
      end

      def get_response
        http         = Net::HTTP.new uri.host, uri.port
        http.use_ssl = uri.scheme == 'https'
        request      = Net::HTTP::Get.new uri.request_uri
        request.basic_auth options[:user], options.fetch(:password, '') if options[:user]
        http.request request
      end

      def uri
        @uri ||= URI "#{url}v1/kv/#{path}?recurse"
      end

    end
  end

  def self.from_consul(url, path, options = {})
    from_env
    sources.add Sources::Consul.new(url, path, options)
  end

  def self.from_consul!(url, path, options = {})
    from_consul url, path, options
    env!
  end

end
