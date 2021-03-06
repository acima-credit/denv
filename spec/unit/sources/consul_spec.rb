# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DEnv::Sources::Consul, :unit do
  include SourceSpecHelpers
  include ConsulSpecHelpers

  let(:url) { 'https://consul.some-domain.com/' }
  let(:uri) { URI url }
  let(:path) { 'service/some_app/vars/' }
  let(:options) { { user: 'some_user', password: 'some_password' } }
  subject { described_class.new url, path, options }
  let(:exp_type) { 'consul' }
  let(:exp_key) { 'c:consul.some-domain.com:service/some_app/vars/' }

  context 'authorized' do
    let(:exp_hsh) { { 'A' => '7', 'D' => '9' } }
    it_behaves_like 'a valid source'
  end
  context 'errors' do
    context 'unauthorized' do
      let(:resp_status) { 401 }
      let(:resp_body) { unauth_body }
      let(:exp_hsh) { {} }
      it_behaves_like 'a valid source'
    end
    context 'timing out' do
      let(:resp_timeout) { true }
      let(:exp_hsh) { {} }
      it_behaves_like 'a valid source'
    end
    context 'exception thrown' do
      let(:resp_exception) { StandardError.new('something went wrong') }
      let(:exp_hsh) { {} }
      it_behaves_like 'a valid source'
    end
  end
end
