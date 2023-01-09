# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DEnv::Sources::Hash, :unit do
  include SourceSpecHelpers

  let(:exp_hsh) do
    { "one" => "1", "two" => "2" }
  end
  let(:exp_type) { "hash" }
  let(:exp_key) { "h:#{exp_hsh.object_id}" }
  subject { described_class.new(exp_hsh) }

  context "valid source" do
    it_behaves_like "a valid source"
  end

  context "invalid source" do
    let(:exp_hsh) { [1, 2] }

    it "raises an error" do
      expect{ subject }.to raise_error(StandardError)
    end
  end
end
