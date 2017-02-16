require 'bundler/setup'
require 'denv'
require 'yaml'
require 'rspec/core/shared_context'
require 'webmock/rspec'
require 'vcr'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.order                                = 'random'
  config.default_formatter                    = :documentation if ENV['PRETTY']
  config.run_all_when_everything_filtered     = true
  config.filter_run focus: true if ENV['FOCUS'].to_s == 'true'
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end

unless ENV.fetch('DEBUG', 'false') == 'true'
  path = DEnv.gem_root.join('spec/spec.log')
  FileUtils.rm_f path
  DEnv.logger = Logger.new path
end

require 'support/helpers'
require 'support/vcr'