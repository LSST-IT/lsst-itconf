# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-daq-mgt.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'PowerEdge R630',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'daq-mgt',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'
      it { is_expected.to contain_host('auxtel-sm').with_ip('192.168.101.2') }
      it { is_expected.to have_nm__connection_resource_count(7) }

      %w[
        eno3
        eno4
        enp4s0f1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with eno1' do
        let(:interface) { 'eno1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with eno2' do
        let(:interface) { 'eno2' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm manual interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('192.168.101.1/24') }
      end

      context 'with enp4s0f0' do
        let(:interface) { 'enp4s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm bridge slave interface', master: 'lsst-daq'
        it { expect(nm_keyfile['ethtool']['ring-rx']).to eq(4096) }
        it { expect(nm_keyfile['ethtool']['ring-tx']).to eq(4096) }
      end

      context 'with lsst-daq' do
        let(:interface) { 'lsst-daq' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm bridge interface'
        it_behaves_like 'nm manual interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('192.168.100.1/24') }
      end

      it { is_expected.to contain_class('nfs::server').with_nfs_v4(false) }
      it { is_expected.to contain_nfs__server__export('/srv/nfs/dsl') }
      it { is_expected.to contain_nfs__server__export('/srv/nfs/lsst-daq') }
    end # on os
  end # on_supported_os
end
