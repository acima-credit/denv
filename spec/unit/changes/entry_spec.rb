# frozen_string_literal: true

require 'spec_helper'

class DEnv
  class Changes
    RSpec.describe Entry, :unit do
      let(:key) { 'some_key' }
      let(:value) { 'some_value' }
      let(:origin) { 'file:.env' }
      subject { described_class.new key, value, origin }
      it { expect(subject.key).to eq key }
      it { expect(subject.value).to eq value }
      it { expect(subject.origin).to eq origin }
      it { expect(subject.to_a).to eq %w[some_key some_value file:.env] }
      it { expect(subject.to_s).to eq '[CE:some_key:some_value:file:.env]' }
    end
  end
end
