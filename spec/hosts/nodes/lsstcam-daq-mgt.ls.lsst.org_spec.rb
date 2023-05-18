# frozen_string_literal: true

require 'spec_helper'

describe 'lsstcam-daq-mgt.ls.lsst.org', :site do
  on_supported_os.each do |os, facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) { facts.merge(fqdn: 'lsstcam-daq-mgt.ls.lsst.org') }

      let(:node_params) do
        {
          role: 'daq-mgt',
          site: 'ls',
          variant: '1114s',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_context 'with nm interface'
      it { is_expected.to have_network__interface_resource_count(0) }
      it { is_expected.to have_profile__nm__connection_resource_count(8) }

      %w[
        eno1np0
        eno2np1
        enp4s0f3u2u2c2
        enp197s0f1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with enp129s0f1' do
        let(:interface) { 'enp129s0f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('192.168.101.1/24') }
        it { expect(nm_keyfile['ipv4']['ignore-auto-dns']).to be true }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
      end

      context 'with enp129s0f0' do
        let(:interface) { 'enp129s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with enp197s0f0' do
        let(:interface) { 'enp197s0f0' }

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
        it { expect(nm_keyfile['ipv4']['address1']).to eq('192.168.100.1/24') }
        it { expect(nm_keyfile['ipv4']['ignore-auto-dns']).to be true }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
      end

      it { is_expected.to contain_class('nfs::server').with_nfs_v4(false) }
      it { is_expected.to contain_nfs__server__export('/srv/nfs/dsl') }
      it { is_expected.to contain_nfs__server__export('/srv/nfs/lsst-daq') }
    end # on os
  end # on_supported_os
end
