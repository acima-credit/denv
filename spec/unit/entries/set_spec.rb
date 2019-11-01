# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DEnv::Entries::Set, :unit do
  let(:entry_class) { DEnv::Entries::Entry }

  let(:entries) { [entry_class.new('A', '1'), entry_class.new('B', '2')] }
  subject { described_class.new.tap { |x| entries.each { |y| x.set y } } }
  context 'basic' do
    it { expect(subject.values).to eq entries }
    it { expect(subject.size).to eq entries.size }
    it { expect(subject.map { |x| x }).to eq entries }
    it { expect(subject['A']).to eq entries.first }
    it { expect(subject.get('B')).to eq entries.last }
    it { expect(subject.to_hash).to eq('A' => '1', 'B' => '2') }
    it { expect(subject.to_safe_hash('B')).to eq('A' => '1', 'B' => '*') }
    it { expect(subject.to_s).to eq '#<DEnv::Entries::Set keys=2>' }
    it { expect(subject.inspect).to eq '#<DEnv::Entries::Set keys=2>' }
  end
  context 'adding' do
    context 'valid' do
      context 'full value' do
        let(:entries) { [entry_class.new('A', '1')] }
        it { expect(subject.size).to eq 1 }
      end
      context 'empty value' do
        let(:entries) { [entry_class.new('A', ' ')] }
        it { expect(subject.size).to eq 1 }
      end
      context 'missing value' do
        let(:entries) { [entry_class.new('A', nil)] }
        it { expect(subject.size).to eq 1 }
      end
    end
    context 'commented out' do
      let(:entries) { [entry_class.new('#A', '1')] }
      it { expect(subject.size).to eq 0 }
    end
    context 'empty key' do
      let(:entries) { [entry_class.new(' ', '1')] }
      it { expect(subject.size).to eq 0 }
    end
  end
end
