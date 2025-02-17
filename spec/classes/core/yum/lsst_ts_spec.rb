# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::yum::lsst_ts' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_yumrepo('lsst-ts').with(
          descr: 'LSST Telescope and Site Packages',
          ensure: 'present',
          enabled: true
        )
      end
    end
  end
end
