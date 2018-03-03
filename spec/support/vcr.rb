# frozen_string_literal: true

WebMock.disable_net_connect!

VCR.configure do |c|
  # c.ignore_request { |_| !ENV['CI'].nil? }
  c.cassette_library_dir     = 'spec/cassettes'
  c.default_cassette_options = { record: :once, erb: true, serialize_with: :yaml }
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.preserve_exact_body_bytes do |http_message|
    http_message.body.encoding.name == 'ASCII-8BIT' || !http_message.body.valid_encoding?
  end
end
