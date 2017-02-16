require 'spec_helper'

class DEnv
  class Entries
    RSpec.describe Entry, :unit do
      let(:key) { 'some_key' }
      let(:value) { 'some_value' }
      let(:time) { Time.new 2000, 2, 15, 3, 15, 45 }
      subject { described_class.new key, value, time }
      let(:other) { described_class.new key, 'other_value' }
      let(:another) { described_class.new 'other_key', 'other_value' }
      # attributes
      it { expect(subject.key).to eq key }
      it { expect(subject.value).to eq value }
      it { expect(subject.time).to eq time }
      # equality
      it { expect(subject.eql?(subject)).to be_truthy }
      it { expect(subject.eql?(other)).to be_falsey }
      it { expect(subject.eql?(another)).to be_falsey }
      # ordering
      it { expect(subject.<=>(subject)).to eq 0 }
      it { expect(subject.<=>(other)).to eq 0 }
      it { expect(subject.<=>(another)).to eq 1 }
    end
  end
end
