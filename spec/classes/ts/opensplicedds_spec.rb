# frozen_string_literal: true

require 'spec_helper'

describe 'profile::ts::opensplicedds' do
  context 'with no params' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_yumrepo('lsst-ts-private') }

    it do
      is_expected.to contain_package('OpenSpliceDDS')
        .with_ensure('6.10.4-6.el7')
        .that_requires('Yumrepo[lsst-ts-private]')
    end
  end

  context 'with ensure param' do
    let(:params) { { ensure: '1.2.3-1.el7' } }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_yumrepo('lsst-ts-private') }

    it do
      is_expected.to contain_package('OpenSpliceDDS')
        .with_ensure('1.2.3-1.el7')
        .that_requires('Yumrepo[lsst-ts-private]')
    end
  end
end
