require 'spec_helper'

class DEnv
  class Entries
    RSpec.describe Set, :unit do
      let(:entries) { [Entry.new('A', '1'), Entry.new('B', '2')] }
      subject { described_class.new.tap { |x| entries.each { |y| x.set y } } }
      context 'basic' do
        it { expect(subject.values).to eq entries }
        it { expect(subject.size).to eq entries.size }
        it { expect(subject.map { |x| x }).to eq entries }
        it { expect(subject['A']).to eq entries.first }
        it { expect(subject.get('B')).to eq entries.last }
        it { expect(subject.to_hash).to eq({ 'A' => '1', 'B' => '2' }) }
        it { expect(subject.to_safe_hash('B')).to eq({ 'A' => '1', 'B' => '*' }) }
        it { expect(subject.to_s).to eq '#<DEnv::Entries::Set keys=2>' }
        it { expect(subject.inspect).to eq '#<DEnv::Entries::Set keys=2>' }
      end
      context 'adding' do
        context 'valid' do
          context 'full value' do
            let(:entries) { [Entry.new('A', '1')] }
            it { expect(subject.size).to eq 1 }
          end
          context 'empty value' do
            let(:entries) { [Entry.new('A', ' ')] }
            it { expect(subject.size).to eq 1 }
          end
          context 'missing value' do
            let(:entries) { [Entry.new('A', nil)] }
            it { expect(subject.size).to eq 1 }
          end
        end
        context 'commented out' do
          let(:entries) { [Entry.new('#A', '1')] }
          it { expect(subject.size).to eq 0 }
        end
        context 'empty key' do
          let(:entries) { [Entry.new(' ', '1')] }
          it { expect(subject.size).to eq 0 }
        end
      end
    end
  end
end
