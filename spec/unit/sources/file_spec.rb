# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DEnv::Sources::File, :unit do
  include SourceSpecHelpers

  let(:root) { nil }
  subject { described_class.new path, root }
  let(:exp_type) { 'file' }
  let(:exp_key) { "f:#{File.basename(path)}" }

  context 'found' do
    context 'without root' do
      let(:path) { '../../envs/a/.env' }
      let(:exp_hsh) { { 'A' => '1', 'B' => '2' } }
      it_behaves_like 'a valid source'
    end
    context 'with root' do
      let(:root) { DEnv.gem_root.join('spec').to_s }
      let(:path) { 'envs/a/.env' }
      let(:exp_hsh) { { 'A' => '1', 'B' => '2' } }
      it_behaves_like 'a valid source'
    end
    context 'complex' do
      let(:path) { '../../envs/a/.complex.env' }
      let(:exp_hsh) { { 'D' => 'X=1&Z=2', 'LDAP_USERNAME' => 'CN=Finance Portal,OU=Users' } }
      it_behaves_like 'a valid source'
    end
  end
  context 'not found' do
    let(:exp_hsh) { {} }
    context 'without root' do
      let(:path) { '../../envs/a/.missing' }
      it_behaves_like 'a valid source'
    end
    context 'with root' do
      let(:root) { DEnv.gem_root.join('spec').to_s }
      let(:path) { 'envs/a/.missing' }
      it_behaves_like 'a valid source'
    end
  end
end
