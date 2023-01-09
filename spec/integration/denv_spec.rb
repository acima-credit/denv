# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DEnv, :clean_env do
  it('version') { expect(DEnv::VERSION).to eq '0.4.0' }

  context 'with', :integration, :clean_env do
    let(:new_env) { { 'A' => '8', 'D' => '7', 'E' => 'extra' } }
    let(:nv_key) { 'env' }
    let(:env_path) { '../envs/a/.env' }
    let(:env_key) { %(f:#{::File.basename(env_path)}) }
    let(:local_path) { '../envs/a/.local.env' }
    let(:local_key) { %(f:#{::File.basename(local_path)}) }
    let(:consul_args) { ['https://consul.some-domain.com/', 'service/some_app/vars/', { user: 'some_user', password: 'some_password' }] }
    let(:consul_key) { 'c:consul.some-domain.com:service/some_app/vars/' }
    let(:credentials_hash) { { Z: 'Z value', Y: 'Y value' } }
    let(:credentials_location) { nil }
    let(:cred_key) { %(c:credentials) }

    context 'change and update always' do
      shared_examples 'a valid setup and update' do
        it('works') do
          expect(DEnv.sources.keys).to eq(exp_keys)
          expect(DEnv.changes).to eq(exp_changes)
          DEnv.env!
          expect(ENV.to_hash).to eq(exp_env)
        end
      end
      context '.env file' do
        before { DEnv.from_file(env_path) }
        let(:exp_keys) { [env_key] }
        let(:exp_changes) { { 'A' => '1', 'B' => '2' } }
        let(:exp_env) { { 'A' => '1', 'D' => '7', 'E' => 'extra', 'B' => '2' } }
        it_behaves_like 'a valid setup and update'
      end
      context '.local.env file' do
        before { DEnv.from_file(local_path) }
        let(:exp_keys) { [local_key] }
        let(:exp_changes) { { 'B' => '3', 'C' => '5' } }
        let(:exp_env) { {} }
        let(:exp_env) { new_env.update exp_changes }
        it_behaves_like 'a valid setup and update'
      end
      context 'rails_credentials' do
        before { DEnv.from_credentials(credentials_hash, credentials_location: nil) }
        let(:exp_keys) { [cred_key] }
        let(:exp_changes) { { 'Z' => 'Z value', 'Y' => 'Y value' } }
        let(:exp_env) { {} }
        let(:exp_env) { new_env.update exp_changes }
        it_behaves_like 'a valid setup and update'
      end
      context 'both .env and .local.env files' do
        before { DEnv.from_file(env_path).from_file(local_path) }
        let(:exp_keys) { [env_key, local_key] }
        let(:exp_changes) { { 'A' => '1', 'B' => '3', 'C' => '5' } }
        let(:exp_env) { { 'A' => '1', 'D' => '7', 'E' => 'extra', 'B' => '3', 'C' => '5' } }
        it_behaves_like 'a valid setup and update'
      end
      context 'all .env, .local.env and rails_credentials' do
        before do
          DEnv
            .from_file(env_path)
            .from_file(local_path)
            .from_credentials(credentials_hash, credentials_location: credentials_location)
        end
        let(:exp_keys) { [env_key, local_key, cred_key] }
        let(:exp_changes) { { 'A' => '1', 'B' => '3', 'C' => '5', 'Y' => 'Y value', 'Z' => 'Z value' } }
        let(:exp_env) { { 'A' => '1', 'D' => '7', 'E' => 'extra', 'B' => '3', 'C' => '5', 'Y' => 'Y value', 'Z' => 'Z value' } }
        it_behaves_like 'a valid setup and update'
      end
    end

    context 'change and update only on append' do
      shared_examples 'a valid setup and update' do
        it('works') do
          DEnv.append_env!
          expect(ENV.to_hash).to eq(exp_env)
        end
      end
      context '.env file' do
        before { DEnv.from_file(env_path) }
        let(:exp_env) { new_env.merge 'B' => '2' }
        it_behaves_like 'a valid setup and update'
      end
      context '.local.env file' do
        before { DEnv.from_file(local_path) }
        let(:exp_env) { new_env.merge 'B' => '3', 'C' => '5' }
        it_behaves_like 'a valid setup and update'
      end
      context 'rails_credentials' do
        before { DEnv.from_credentials(credentials_hash, credentials_location: credentials_location) }
        let(:exp_env) { new_env.merge 'Y' => 'Y value', 'Z' => 'Z value' }
        it_behaves_like 'a valid setup and update'
      end
      context 'both .env and .local.env files' do
        before { DEnv.from_file(env_path).from_file(local_path) }
        let(:exp_env) { new_env.merge 'B' => '3', 'C' => '5' }
        it_behaves_like 'a valid setup and update'
      end
    end

    context 'update!' do
      shared_examples 'a valid update!' do
        it('works') do
          expect(DEnv.sources.keys).to eq(exp_keys)
          expect(ENV.to_hash).to eq(exp_env)
        end
      end
      context '.env file' do
        before { DEnv.from_file!(env_path) }
        let(:exp_keys) { [env_key] }
        let(:exp_changes) { { 'A' => '1', 'B' => '2' } }
        let(:exp_env) { { 'A' => '1', 'D' => '7', 'E' => 'extra', 'B' => '2' } }
        it_behaves_like 'a valid update!'
      end
      context '.local.env file' do
        before { DEnv.from_file!(local_path) }
        let(:exp_keys) { [local_key] }
        let(:exp_changes) { { 'B' => '3', 'C' => '5' } }
        let(:exp_env) { { 'A' => '8', 'D' => '7', 'E' => 'extra', 'B' => '3', 'C' => '5' } }
        it_behaves_like 'a valid update!'
      end
      context 'consul', :vcr do
        before { DEnv.from_consul!(*consul_args) }
        let(:exp_keys) { [consul_key] }
        let(:exp_changes) { { 'A' => '7', 'D' => '9' } }
        let(:exp_env) { { 'A' => '7', 'D' => '9', 'E' => 'extra' } }
        it_behaves_like 'a valid update!'
      end
      context 'rails_credentials' do
        before { DEnv.from_credentials!(credentials_hash, credentials_location: credentials_location) }
        let(:exp_keys) { [cred_key] }
        let(:exp_env) { new_env.merge('Z' => 'Z value', 'Y' => 'Y value') }
        it_behaves_like 'a valid update!'
      end
      context 'both .env and .local.env files' do
        before { DEnv.from_file(env_path).from_file!(local_path) }
        let(:exp_keys) { [env_key, local_key] }
        let(:exp_changes) { { 'A' => '1', 'B' => '3', 'C' => '5' } }
        let(:exp_env) { { 'A' => '1', 'D' => '7', 'E' => 'extra', 'B' => '3', 'C' => '5' } }
        it_behaves_like 'a valid update!'
      end
      context 'both .env and .local.env files and consul', :vcr do
        before { DEnv.from_file(env_path).from_file(local_path).from_consul!(*consul_args) }
        let(:exp_keys) { [env_key, local_key, consul_key] }
        let(:exp_changes) { { 'A' => '7', 'B' => '3', 'C' => '5', 'D' => '9' } }
        let(:exp_env) { { 'A' => '7', 'D' => '9', 'E' => 'extra', 'B' => '3', 'C' => '5' } }
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

    context 'reload! and reload! and reload!' do
      context 'with out rails_credentials' do
        let(:new_env) { { 'B' => '0' } }
        let(:changes) { new_env.update 'B' => '2' }
        let(:env_path) { '../envs/b/.env' }
        let(:local_path) { '../envs/b/.local.env' }
        it 'works' do
          DEnv.from_file(env_path).from_file!(local_path)
          expect(ENV.to_hash).to eq(changes)
          DEnv.reload!
          expect(ENV.to_hash).to eq(changes)
          DEnv.reload!
          expect(ENV.to_hash).to eq(changes)
          DEnv.reload!
          expect(ENV.to_hash).to eq(changes)
        end
      end
      context 'with rails_credentials' do
        let(:new_env) { { 'B' => '0' } }
        let(:changes) { new_env.update('B' => '2', 'Y' => 'Y value', 'Z' => 'Z value') }
        let(:env_path) { '../envs/b/.env' }
        let(:local_path) { '../envs/b/.local.env' }
        let(:credentials_location) { 'test' }
        let(:application_double) { double(credentials: credentials_double) }
        let(:credentials_double) { double(read: edited_creds) }
        let(:rails_double) { double(application: application_double) }
        let(:edited_creds) do
          "test:\n" \
            "  Y: 'Y value'\n" \
            '  Z: \'Z value\''
        end

        before { stub_const('Rails', rails_double) }

        it 'works', :aggregate_failures do
          DEnv
            .from_file(env_path)
            .from_file(local_path)
            .from_credentials!(credentials_hash, credentials_location: credentials_location)

          expect(ENV.to_hash).to eq(changes)
          DEnv.reload!
          expect(ENV.to_hash).to eq(changes)
          DEnv.reload!
          expect(ENV.to_hash).to eq(changes)
          DEnv.reload!
          expect(ENV.to_hash).to eq(changes)
        end
      end
    end

    context 'safe changes' do
      before { DEnv.from_file(env_path) }
      let(:exp_changes) { { 'A' => '1', 'B' => '2' } }
      let(:exp_safe_changes) { { 'A' => '*', 'B' => '2' } }
      it 'works' do
        expect(DEnv.safe_changes('a')).to eq(exp_safe_changes)
        expect(DEnv.changes).to eq(exp_changes)
        expect(DEnv.safe_changes('a')).to eq(exp_safe_changes)
      end
    end

    context 'repeat files' do
      let(:env_path) { '../envs/c/.env' }
      let(:local_path) { '../envs/c/.local.env' }
      context 'separately' do
        let(:first_merged_changes) { new_env.merge 'C' => '2' }
        let(:second_merged_changes) { new_env.merge 'C' => '1' }
        it 'respects the files and order' do
          DEnv.from_file(env_path).from_file!(local_path)
          expect(ENV.to_hash).to eq(first_merged_changes)
          DEnv.from_file!(env_path)
          expect(ENV.to_hash).to eq(second_merged_changes)
        end
      end
      context 'together' do
        let(:exp_changes) { new_env.merge 'C' => '1' }
        it 'respects the files and order' do
          DEnv.from_file(env_path).from_file(local_path).from_file!(env_path)
          expect(ENV.to_hash).to eq(exp_changes)
        end
      end
    end

    context 'strip_env!' do
      let(:new_env) { { 'A ' => ' 8', ' D' => '7 ', ' E ' => ' extra ', 'F' => '1' } }
      before { DEnv.strip_env! }
      it 'strips keys and values' do
        expect(ENV.keys.sort).to eq %w[A D E F]
        expect(ENV['A']).to eq '8'
        expect(ENV['D']).to eq '7'
        expect(ENV['E']).to eq 'extra'
        expect(ENV['F']).to eq '1'
      end
    end

    context 'list_env' do
      it 'lists all env vars' do
        expect(DEnv.list_env).to eq [%w[A 8], %w[D 7], %w[E extra]]
      end
    end

    context 'print_env' do
      let(:result) do
        <<~RES
          ENV : "A" : "8"
          ENV : "D" : "7"
          ENV : "E" : "extra"
        RES
      end
      it 'prints all env vars' do
        expect { DEnv.print_env }.to output(result).to_stdout
      end
    end
  end
end
