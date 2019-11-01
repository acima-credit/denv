# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DEnv::Entries::Entry, :unit do
  let(:key) { 'some_key' }
  let(:value) { 'some_value' }
  let(:time) { Time.new 2000, 2, 15, 3, 15, 45 }
  subject { described_class.new key, value, time }
  let(:other) { described_class.new key, 'other_value' }
  let(:another) { described_class.new 'other_key', 'other_value' }
  context 'valid' do
    context 'full' do
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
      # validity
      it { expect(subject).to be_valid }
      it { expect(subject).to_not be_invalid }
    end
    context 'empty value' do
      subject { described_class.new key, ' ' }
      it { expect(subject).to be_valid }
      it { expect(subject).to_not be_invalid }
    end
    context 'cleaning' do
      context 'empty ends' do
        subject { described_class.new " #{key} ", " #{value} " }
        it { expect(subject.key).to eq key }
        it { expect(subject.value).to eq value }
      end
      context 'expand new lines' do
        let(:value) { "A\nB\r\nC" }
        subject { described_class.new key, 'A\\nB\\r\\nC' }
        it { expect(subject.key).to eq key }
        it { expect(subject.value).to eq value }
      end
      context 'unescape characters' do
        let(:value) { 'S0me#alu3' }
        subject { described_class.new key, "S0me\#alu3" }
        it { expect(subject.key).to eq key }
        it { expect(subject.value).to eq value }
      end
    end
  end
  context 'invalid' do
    context 'commented out' do
      subject { described_class.new "##{key}", value }
      it { expect(subject).to_not be_valid }
      it { expect(subject).to be_invalid }
    end
    context 'missing key' do
      subject { described_class.new nil, value }
      it { expect(subject).to_not be_valid }
      it { expect(subject).to be_invalid }
    end
    context 'empty key' do
      subject { described_class.new ' ', value }
      it { expect(subject).to_not be_valid }
      it { expect(subject).to be_invalid }
    end
  end
end
