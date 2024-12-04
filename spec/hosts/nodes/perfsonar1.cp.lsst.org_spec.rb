# frozen_string_literal: true

require 'spec_helper'

describe 'perfsonar1.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'AS -1114S-WN10RT',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'perfsonar',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(5) }

      context 'with eno1np0' do
        let(:interface) { 'eno1np0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ethtool']['ring-rx']).to eq(2047) }
        it { expect(nm_keyfile['ethtool']['ring-tx']).to eq(2047) }
      end

      context 'with enp1s0f0' do
        let(:interface) { 'enp1s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm manual interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.140.13/31') }
        it { expect(nm_keyfile['ipv4']['gateway']).to eq('139.229.140.12') }
        it { expect(nm_keyfile['ethernet']['mtu']).to eq(9000) }
        it { expect(nm_keyfile['ipv4']['route1']).to eq('198.17.196.0/24,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route2']).to eq('198.32.252.39/32,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route3']).to eq('198.32.252.192/31,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route4']).to eq('198.32.252.208/31,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route5']).to eq('198.32.252.210/31,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route6']).to eq('198.32.252.216/31,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route7']).to eq('198.32.252.218/31,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route8']).to eq('198.32.252.232/31,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route9']).to eq('198.32.252.234/31,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route10']).to eq('199.36.153.8/30,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route11']).to eq('134.79.235.226/32,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route12']).to eq('134.79.235.242/32,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route13']).to eq('198.124.226.194/32,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route14']).to eq('198.124.226.198/32,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route15']).to eq('198.124.226.202/32,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route16']).to eq('198.124.226.206/32,139.229.140.12') }
      end

      context 'with enp1s0f1' do
        let(:interface) { 'enp1s0f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm manual interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.140.15/31') }
        it { expect(nm_keyfile['ipv4']['gateway']).to eq('139.229.140.14') }
        it { expect(nm_keyfile['ethernet']['mtu']).to eq(9000) }
        it { expect(nm_keyfile['ipv4']['route1']).to eq('134.79.235.226/32,139.229.140.14') }
        it { expect(nm_keyfile['ipv4']['route2']).to eq('198.17.196.0/24,139.229.140.14') }
        it { expect(nm_keyfile['ipv4']['route3']).to eq('198.32.252.194/31,139.229.140.14') }
        it { expect(nm_keyfile['ipv4']['route4']).to eq('199.36.153.8/30,139.229.140.14') }
        it { expect(nm_keyfile['ipv4']['route5']).to eq('134.79.235.226/32,139.229.140.14') }
        it { expect(nm_keyfile['ipv4']['route6']).to eq('134.79.235.242/32,139.229.140.14') }
        it { expect(nm_keyfile['ipv4']['route7']).to eq('198.124.226.130/32,139.229.140.14') }
        it { expect(nm_keyfile['ipv4']['route8']).to eq('198.124.226.134/32,139.229.140.14') }
        it { expect(nm_keyfile['ipv4']['route9']).to eq('198.124.226.138/32,139.229.140.14') }
        it { expect(nm_keyfile['ipv4']['route10']).to eq('198.124.226.142/32,139.229.140.14') }
      end

      context 'with enp129s0f0np0' do
        let(:interface) { 'enp129s0f0np0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm manual interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.140.9/31') }
        it { expect(nm_keyfile['ipv4']['gateway']).to eq('139.229.140.8') }
        it { expect(nm_keyfile['ethernet']['mtu']).to eq(9000) }
        it { expect(nm_keyfile['ipv4']['route1']).to eq('172.24.7.0/24,139.229.140.8') }
        it { expect(nm_keyfile['ethtool']['ring-rx']).to eq(8192) }
        it { expect(nm_keyfile['ethtool']['ring-tx']).to eq(8192) }
      end

      context 'with enp129s0f1np1' do
        let(:interface) { 'enp129s0f1np1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm manual interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.140.11/31') }
        it { expect(nm_keyfile['ipv4']['gateway']).to eq('139.229.140.10') }
        it { expect(nm_keyfile['ethernet']['mtu']).to eq(9000) }
        it { expect(nm_keyfile['ipv4']['route1']).to eq('172.24.7.0/24,139.229.140.10') }
        it { expect(nm_keyfile['ethtool']['ring-rx']).to eq(8192) }
        it { expect(nm_keyfile['ethtool']['ring-tx']).to eq(8192) }
      end
    end # on os
  end # on_supported_os
end
