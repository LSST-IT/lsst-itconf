# frozen_string_literal: true

require 'spec_helper'

describe 'daq-mgt.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'daq-mgt.tu.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'PowerEdge R530',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'daq-mgt',
          site: 'tu',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(4) }

      context 'with enp5s0f0' do
        let(:interface) { 'enp5s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
      end

      context 'with enp4s0f0' do
        let(:interface) { 'enp4s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm bridge slave interface', master: 'lsst-daq'
        it { expect(nm_keyfile['ethtool']['ring-rx']).to eq(4000) }
        it { expect(nm_keyfile['ethtool']['ring-tx']).to eq(4000) }
      end

      context 'with lsst-daq' do
        let(:interface) { 'lsst-daq' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm bridge interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('192.168.100.1/24') }
        it { expect(nm_keyfile['ipv4']['ignore-auto-dns']).to be true }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
      end

      context 'with eno4' do
        let(:interface) { 'eno4' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('10.0.0.1/24') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
      end
    end # on os
  end # on_supported_os
end
