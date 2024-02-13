# frozen_string_literal: true

require 'spec_helper'

describe 'rancher01.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'rancher01.tu.lsst.org',
                       is_virtual: true,
                       virtual: 'kvm',
                       dmi: {
                         'product' => {
                           'name' => 'KVM',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'rke',
          site: 'tu',
          cluster: 'rancher',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_class('profile::core::rke').with(
          version: '1.4.6',
        )
      end

      include_examples 'vm'
      it { is_expected.to have_nm__connection_resource_count(0) }
    end # on os
  end # on_supported_os
end
