require 'spec_helper'

RSpec.describe DEnv do
  include EnvSpecHelpers

  it('version') { expect(DEnv::VERSION).to eq '0.1.0' }

  context 'with', :integration, :clean_env do
    let(:new_env) { { 'A' => '8', 'D' => '7' } }
    let(:merged_changes) { new_env.update exp_changes }
    let(:nv_key) { 'env' }
    let(:env_path) { '../envs/a/.env' }
    let(:env_key) { "f:#{::File.basename(env_path)}" }
    let(:local_path) { '../envs/a/.local.env' }
    let(:local_key) { "f:#{::File.basename(local_path)}" }
    let(:consul_args) { ['https://consul.some-domain.com/', 'service/some_app/vars/', { user: 'some_user', password: 'some_password' }] }
    let(:consul_key) { 'c:consul.some-domain.com:service/some_app/vars/' }

    context 'change and update' do
      shared_examples 'a valid setup and update' do
        it('works') do
          expect(DEnv.sources.keys).to eq(exp_keys)
          expect(DEnv.changes).to eq(exp_changes)
          DEnv.env!
          expect(ENV.to_hash).to eq(merged_changes)
        end
      end
      context '.env file' do

        before { DEnv.from_file(env_path) }
        let(:exp_keys) { [nv_key, env_key] }
        let(:exp_changes) { { 'A' => '1', 'B' => '2' } }
        it_behaves_like 'a valid setup and update'
      end
      context '.local.env file' do
        before { DEnv.from_file(local_path) }
        let(:exp_keys) { [nv_key, local_key] }
        let(:exp_changes) { { 'B' => '3', 'C' => '5' } }
        it_behaves_like 'a valid setup and update'
      end
      context 'both .env and .local.env files' do
        before { DEnv.from_file(env_path).from_file(local_path) }
        let(:exp_keys) { [nv_key, env_key, local_key] }
        let(:exp_changes) { { 'A' => '1', 'B' => '3', 'C' => '5' } }
        it_behaves_like 'a valid setup and update'
      end
    end

    context 'update!' do
      shared_examples 'a valid update!' do
        it('works') do
          expect(DEnv.sources.keys).to eq(exp_keys)
          expect(ENV.to_hash).to eq(merged_changes)
        end
      end
      context '.env file' do
        before { DEnv.from_file!(env_path) }
        let(:exp_keys) { [nv_key, env_key] }
        let(:exp_changes) { { 'A' => '1', 'B' => '2' } }
        it_behaves_like 'a valid update!'
      end
      context '.local.env file' do
        before { DEnv.from_file!(local_path) }
        let(:exp_keys) { [nv_key, local_key] }
        let(:exp_changes) { { 'B' => '3', 'C' => '5' } }
        it_behaves_like 'a valid update!'
      end
      context 'consul', :vcr do
        before { DEnv.from_consul!(*consul_args) }
        let(:exp_keys) { [nv_key, consul_key] }
        let(:exp_changes) { { 'A' => '7', 'D' => '9' } }
        it_behaves_like 'a valid update!'
      end
      context 'both .env and .local.env files' do
        before { DEnv.from_file(env_path).from_file!(local_path) }
        let(:exp_keys) { [nv_key, env_key, local_key] }
        let(:exp_changes) { { 'A' => '1', 'B' => '3', 'C' => '5' } }
        it_behaves_like 'a valid update!'
      end
      context 'both .env and .local.env files and consul', :vcr do
        before { DEnv.from_file(env_path).from_file(local_path).from_consul!(*consul_args) }
        let(:exp_keys) { [nv_key, env_key, local_key, consul_key] }
        let(:exp_changes) { { 'A' => '7', 'B' => '3', 'C' => '5', 'D' => '9' } }
        it_behaves_like 'a valid update!'
      end
    end

    context 'update! and reload!' do
      let(:first_merged_changes) { new_env.update 'A' => '1', 'B' => '2' }
      let(:second_merged_changes) { new_env.update 'A' => '1', 'B' => '3' }
      it 'works' do
        DEnv.from_file!(env_path)
        expect(ENV.to_hash).to eq(first_merged_changes)
        changing_file('envs/a/.env', 'A=1\nB=3') do
          DEnv.reload!
          expect(ENV.to_hash).to eq(second_merged_changes)
        end
      end
    end
  end
end
