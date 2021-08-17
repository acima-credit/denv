# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'fakefs/spec_helpers'

describe DEnv::Sources::SecretsDir do
  include SourceSpecHelpers

  subject { described_class.new path }

  let(:exp_type) { 'secrets_dir' }
  let(:exp_key) { "s:#{::File.basename(path)}" }

  context 'when condition', fakefs: true do
    let(:path) { Pathname.new("#{__dir__}/../../envs") }
    before do
      FakeFS::FileSystem.clone(path)
      FakeFS::FileUtils.mkdir_p('secrets')
    end
    context 'succeeds empty' do
      let(:exp_hsh) { {} }
      it_behaves_like 'a valid source'
    end
    context 'has one secret key' do
      let(:value) { 'my_secret_boi' }
      let(:file_name) { 'SECRET_KEY' }
      let(:parent_hsh) { { file_name => value } }
      let(:exp_hsh) { parent_hsh }
      before { File.write("#{path}/#{file_name}", value) }
      it_behaves_like 'a valid source'
      context 'has one added key' do
        let(:new_hsh) { { 'SECRET_KEY_1' => 'my_next_secret' } }
        let(:exp_hsh) { new_hsh.merge parent_hsh }
        before { File.write("#{path}/#{new_hsh.keys.first}", new_hsh.values.first) }
        it_behaves_like 'a valid source'
      end
      context 'has one updated key' do
        let(:new_value) { 'my_secret_boi_part_2' }
        it_behaves_like 'a valid source'
        it 'handles the updated file' do
          DEnv.from_secrets_dir! path
          expect(ENV[file_name]).to eq value
          File.write("#{path}/#{file_name}", new_value)
          DEnv.reload!
          expect(ENV[exp_hsh.keys.first]).to eq new_value
        end
        it 'has one deleted key' do
          secrets = DEnv::Sources::SecretsDir.new(path)
          expect(secrets.to_hash[file_name]).to eq value
          File.delete("#{path}/#{file_name}")
          secrets.reload
          expect(secrets.to_hash[file_name]).to eq nil
        end
      end
      context 'handles bad data' do
        let(:value) { '' }
        before { File.write("#{path}/#{exp_hsh.keys.first}", value) }
        it 'deals with an empty secrets sub file' do
          DEnv.from_secrets_dir! path
          expect(ENV[file_name]).to eq value
        end
        context 'fails with bad file access permissions' do
          context 'fails with missing directory' do
            before { File.delete(path) }
            it 'dies - missing secrets dir' do
              expect { subject.to_hash }.to raise_exception "Error accessing secret env dir at #{path}"
            end
          end
          context 'fails with inaccessible directories' do
            before { File.chmod(0o00, path) }
            it 'dies - bad dir access' do
              expect { subject.to_hash }.to raise_exception "Error accessing secret env dir at #{path}"
            end
          end
          context 'fails with inaccessible files' do
            let(:file_path) { "#{path}/#{exp_hsh.keys.first}" }
            before { File.chmod(0o00, file_path) }
            it 'dies - bad file access' do
              expect { subject.to_hash }.to raise_exception "Secret file #{file_path} is not accessible"
            end
          end
        end
      end
    end
  end
end
