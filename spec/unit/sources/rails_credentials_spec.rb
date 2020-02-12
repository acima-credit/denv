# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DEnv::Sources::RailsCredentials, :unit do
  include SourceSpecHelpers

  let(:credentials_location) { nil }
  let(:credentials_hash) { { A: 1, 'B' => 2 } }
  subject { described_class.new(credentials_hash, credentials_location) }
  let(:exp_type) { 'credentials' }
  let(:exp_key) { 'c:credentials' }

  context 'hash present' do
    let(:exp_hsh) { { 'A' => '1', 'B' => '2' } }
    it_behaves_like 'a valid source'
  end

  context 'hash missing' do
    let(:credentials_hash) { {} }
    let(:exp_hsh) { {} }
    it_behaves_like 'a valid source'
  end

  describe '#reload' do
    context 'in a rails application' do
      context 'with credentials_location' do
        let(:edited_creds) do
          "test:\n" \
          "  A: 2\n" \
          '  B: 1'
        end
        let(:application_double) { double(credentials: credentials_double) }
        let(:credentials_double) { double(read: edited_creds) }
        let(:rails_double) { double(application: application_double) }
        let(:credentials_location) { 'test' }
        let(:exp_hsh) { { 'A' => 2, 'B' => 1 } }

        before { stub_const('Rails', rails_double) }

        it 'reloads and returns the new edited_creds' do
          expect(subject.reload).to eq(exp_hsh)
        end
      end

      context 'without credentials_location' do
        let(:edited_creds) do
          "test:\n" \
          "  A: 2\n" \
          '  B: 1'
        end
        let(:application_double) { double(credentials: credentials_double) }
        let(:credentials_double) { double(read: edited_creds) }
        let(:rails_double) { double(application: application_double) }
        let(:credentials_location) { nil }

        before { stub_const('Rails', rails_double) }

        it 'reloads but does not return the new edited_creds' do
          expect(subject.reload).to eq(credentials_hash)
        end
      end
    end

    context 'not in a rails application' do
      context 'with credentials_location' do
        let(:credentials_location) { 'test' }

        it 'reloads but does not return the new edited_creds' do
          expect { subject.reload }
            .to raise_error('Cannot load credentials outside of Rails')
        end
      end

      context 'without credentials_location' do
        let(:credentials_location) { nil }

        it 'reloads but does not return the new edited_creds' do
          expect(subject.reload).to eq(credentials_hash)
        end
      end
    end
  end
end
