# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DEnv::Changes::Set, :unit do
  let(:entry_class) { DEnv::Changes::Entry }

  let(:entries) { [entry_class.new('A', '1', 'file:.env'), entry_class.new('B', '2', 'file:.env')] }
  subject { described_class.new.tap { |x| entries.each { |y| x.set y } } }
  context 'basic' do
    it { expect(subject.values).to eq entries }
    it { expect(subject.size).to eq entries.size }
    it { expect(subject.map { |x| x }).to eq entries }
    it { expect(subject.to_hash).to eq('A' => '1', 'B' => '2') }
    it { expect(subject.to_a).to eq([%w[A 1 file:.env], %w[B 2 file:.env]]) }
    it { expect(subject.to_s).to eq '#<DEnv::Changes::Set keys=2>' }
  end
end
