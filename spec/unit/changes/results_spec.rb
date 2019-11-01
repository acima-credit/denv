# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DEnv::Changes::Results, :unit, :clean_env do
  include EnvSpecHelpers
  let(:env_path) { '../../envs/a/.env' }
  let(:local_path) { '../../envs/a/.local.env' }
  context 'both .env and .local.env files' do
    let(:new_env) { { 'A' => '1' } }
    let(:exp_changes) { { 'B' => '3', 'C' => '5' } }
    let(:exp_safe_changes) { { 'B' => '*', 'C' => '5' } }
    let(:exp_env) { { 'A' => '1', 'B' => '3', 'C' => '5' } }
    let(:exp_changes_ary) { [%w[B 3 f:.local.env], %w[C 5 f:.local.env]] }
    before { DEnv.from_file(env_path).from_file(local_path) }
    it 'works' do
      expect(DEnv.changes).to eq(exp_changes)
      expect(DEnv.safe_changes('b')).to eq(exp_safe_changes)
      expect(DEnv.changes_ary).to eq(exp_changes_ary)
      DEnv.env!
      expect(ENV.to_hash).to eq(exp_env)
    end
  end
end
