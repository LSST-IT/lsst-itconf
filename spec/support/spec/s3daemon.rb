# frozen_string_literal: true

shared_examples 's3daemon' do
  it { is_expected.to contain_class('s3daemon') }
end
