require 'spec_helper'

class DEnv
  class Entries
    RSpec.describe Set, :unit do
      let(:entries) { [Entry.new('A', '1'), Entry.new('B', '2')] }
      subject { described_class.new.tap { |x| entries.each { |y| x.set y } } }
      it { expect(subject.values).to eq entries }
      it { expect(subject.size).to eq entries.size }
      it { expect(subject.map { |x| x }).to eq entries }
      it { expect(subject['A']).to eq entries.first }
      it { expect(subject.get('B')).to eq entries.last }
      it { expect(subject.to_hash).to eq({ 'A' => '1', 'B' => '2' }) }
      it { expect(subject.to_s).to eq '#<DEnv::Entries::Set keys=2>' }
      it { expect(subject.inspect).to eq '#<DEnv::Entries::Set keys=2>' }
    end
  end
end
