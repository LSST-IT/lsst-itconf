# frozen_string_literal: true

require 'spec_helper'

describe 'rancher01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
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
          site: 'cp',
          cluster: 'rancher',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'docker', docker_version: '24.0.9'

      it do
        is_expected.to contain_class('rke').with(
          version: '1.6.5',
          checksum: '80694373496abd5033cb97c2512f2c36c933d301179881e1d28bf7b78efab3e7'
        )
      end

      include_examples 'vm'
      include_context 'with nm interface'
      it do
        is_expected.to contain_class('profile::core::sysctl::rp_filter').with_enable(false)
      end

      it { is_expected.to have_nm__connection_resource_count(2) }

      context 'with enp1s0' do
        let(:interface) { 'enp1s0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm dhcp interface'
      end

      context 'with enp2s0' do
        let(:interface) { 'enp2s0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['method']).to eq('disabled') }
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
      end
    end # on os
  end # on_supported_os
end
