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
        "#{type[0,1]}:#{uri.host}:#{path}"
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
        return [] unless response && response.code.to_i == 200

        MultiJson.load response.body
      rescue Exception => e
        DEnv.logger.error 'DEnv : source  : %-15.15s | %s' % [key, "Exception: #{e.class.name} : #{e.message}\n  #{e.backtrace[0, 5].join("\n  ")}"]
        return []
      end

      def get_response
        http_client.request http_request
      rescue Errno::ECONNREFUSED
        DEnv.logger.error 'DEnv : source  : %-15.15s | %s' % [key, "could not connect to #{uri}"]
        return nil
      rescue Net::OpenTimeout
        DEnv.logger.error 'DEnv : source  : %-15.15s | %s' % [key, "timed out trying to connect to #{uri}"]
        return nil
      end

      def http_request
        Net::HTTP::Get.new(uri.request_uri).tap do |request|
          user, password = options[:user], options.fetch(:password, '')
          request.basic_auth user, password if user
        end
      end

      def http_client
        Net::HTTP.new(uri.host, uri.port).tap do |http|
          http.use_ssl = uri.scheme == 'https'
        end
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
