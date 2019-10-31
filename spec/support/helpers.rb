# frozen_string_literal: true

module DEnvSpecHelpers
  extend RSpec::Core::SharedContext

  let(:new_env) { {} }

  def changing_file(path, new_content)
    path        = DEnv.gem_root.join 'spec', path
    old_content = File.read path
    File.open(path, 'w') { |f| f.puts new_content }
    yield
    File.open(path, 'w') { |f| f.puts old_content }
  end
end

RSpec.configure do |config|
  config.include DEnvSpecHelpers

  config.around(:each) do |example|
    DEnv.clear
    example.run
    DEnv.clear
  end
end

module SourceSpecHelpers
  shared_examples 'a valid source' do
    it { expect(subject.type).to eq exp_type }
    it { expect(subject.key).to eq exp_key }
    it { expect(subject.to_hash).to eq(exp_hsh) }
  end
end

module ConsulSpecHelpers
  extend RSpec::Core::SharedContext

  let(:resp_status) { 200 }
  let(:resp_body) { '[{"LockIndex":0,"Key":"service/some_app/vars/","Flags":0,"Value":null,"CreateIndex":4656941,"ModifyIndex":4656941},{"LockIndex":0,"Key":"service/some_app/vars/A","Flags":0,"Value":"Nw==","CreateIndex":4656953,"ModifyIndex":4656953},{"LockIndex":0,"Key":"service/some_app/vars/D","Flags":0,"Value":"OQ==","CreateIndex":4656948,"ModifyIndex":4656948}]' }
  let(:resp_headers) { { 'Content-Type' => 'application/json' } }
  let(:resp_timeout) { false }
  let(:resp_exception) { nil }

  before do
    stub = stub_request(:get, /#{uri.host}/)
    if resp_timeout
      stub.to_timeout
    elsif resp_exception
      stub.to_raise resp_exception
    else
      stub.to_return(status: resp_status, body: resp_body, headers: resp_headers)
    end
  end

  let(:unauth_body) do
    <<~HTML
      <html>
      <head><title>401 Authorization Required</title></head>
      <body bgcolor="white">
      <center><h1>401 Authorization Required</h1></center>
      <hr><center>nginx/1.11.1</center>
      </body>
      </html>
    HTML
  end
  let(:unauth_headers) { { 'Content-Type' => 'text/html' } }
end

module EnvSpecHelpers
  extend RSpec::Core::SharedContext

  let(:new_env) { {} }

  around(:each) do |example|
    old_env = ENV.each_with_object({}) { |(k, v), h| h[k] = v }
    # DEnv.logger.debug 'EnvSpecHelpers : before : 1 : $old_env : %s' % $old_env.inspect
    ENV.clear
    new_env.each { |k, v| ENV[k.to_s] = v.to_s }
    # DEnv.logger.debug 'EnvSpecHelpers : before : 2 : ENV      : %s' % ENV.inspect
    example.run
    # DEnv.logger.debug 'EnvSpecHelpers : after  : 3 : ENV      : %s' % ENV.inspect
    ENV.clear
    old_env.each { |k, v| ENV[k] = v }
    # DEnv.logger.debug 'EnvSpecHelpers : after  : 4 : ENV      : %s' % ENV.inspect
  end
end
