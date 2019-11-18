# frozen_string_literal: true

require 'yaml'

class DEnv
  class Sources
    # Class for loading credentials specifically from Rails
    class RailsCredentials < Base
      attr_reader :credentials_hash, :credentials_location

      def initialize(credentials_hash, credentials_location)
        @credentials_hash = credentials_hash || {}
        @credentials_location = credentials_location
      end

      def type
        'credentials'
      end

      def key
        "#{type[0, 1]}:credentials"
      end

      def reload
        load_new_creds
        super
      end

      private

      def load_new_creds
        return nil if credentials_location.nil? || credentials_location == ''
        return nil unless Object.const_defined?(:Rails)
        return nil if ::Rails&.application&.credentials.nil?

        hash = YAML.safe_load(::Rails.application.credentials.read)
        @credentials_hash = hash[credentials_location]
      end

      def set_entries
        if credentials_hash == {}
          DEnv.logger.error format('DEnv : source  : %-15.15s | %s', key, "could not find credentials")
          return false
        end

        DEnv.logger.debug format('DEnv : source  : %-15.15s | %s', key, "found credentials")
        credentials_hash.each do |key, value|
          add(key.to_s, value.to_s)
        end
      end
    end
  end

  def self.from_credentials(credentials_hash, credentials_location: nil)
    add(Sources::RailsCredentials.new(credentials_hash, credentials_location))
  end

  def self.from_credentials!(credentials_hash, credentials_location: nil)
    from_credentials(credentials_hash, credentials_location: credentials_location)
    env!
  end
end
