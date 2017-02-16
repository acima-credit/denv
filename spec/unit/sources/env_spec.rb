require 'spec_helper'

class DEnv
  class Sources
    RSpec.describe Env, :unit, :clean_env do
      include SourceSpecHelpers
      include EnvSpecHelpers

      subject { described_class.new }
      let(:exp_type) { 'env' }
      let(:exp_key) { exp_type }

      context 'simple' do
        let(:new_env) { { 'A' => '7', 'D' => '9' } }
        let(:exp_hsh) { new_env }
        it_behaves_like 'a valid source'
      end
    end
  end
end
