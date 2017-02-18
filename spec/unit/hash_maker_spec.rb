require 'spec_helper'

class DEnv
  RSpec.describe HashMasker, :unit do
    subject { described_class.new hsh, *pts }
    let(:pts) { ['USER'] }
    shared_examples 'a valid hash masker' do
      it { expect(subject.result).to eq exp }
    end
    context 'keys' do
      let(:hsh) { { 'A' => '1', 'SOME_USER' => '2', 'SOME_PASSWORD' => '1' } }
      let(:exp) { { 'A' => '1', 'SOME_USER' => '*', 'SOME_PASSWORD' => '*' } }
      let(:pts) { ['user', /PASS/i] }
      it_behaves_like 'a valid hash masker'
    end
    context 'value length' do
      context '0-4' do
        let(:hsh) { { 'A' => '1', 'USER_0' => '', 'USER_1' => '1', 'USER_2' => '12', 'USER_3' => '123', 'USER_4' => '1234' } }
        let(:exp) { { 'A' => '1', 'USER_0' => '', 'USER_1' => '*', 'USER_2' => '**', 'USER_3' => '***', 'USER_4' => '****' } }
        it_behaves_like 'a valid hash masker'
      end
      context '5-10' do
        let(:hsh) { { 'A' => '1', 'USER_5' => '12345', 'USER_6' => '123456', 'USER_7' => '1234567', 'USER_8' => '12345678', 'USER_9' => '123456789', 'USER_10' => '1234567890' } }
        let(:exp) { { 'A' => '1', 'USER_5' => '**3**', 'USER_6' => '**34**', 'USER_7' => '**345**', 'USER_8' => '**3456**', 'USER_9' => '**34567**', 'USER_10' => '**345678**' } }
        it_behaves_like 'a valid hash masker'
      end
      context '11-30' do
        let(:hsh) { { 'A' => '1', 'USER_11' => '12345678901', 'USER_21' => '123456789012345678901' } }
        let(:exp) { { 'A' => '1', 'USER_11' => '***45678***', 'USER_21' => '***456789012345678***' } }
        it_behaves_like 'a valid hash masker'
      end
    end
  end
end
