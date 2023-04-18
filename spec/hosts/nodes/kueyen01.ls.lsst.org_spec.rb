# frozen_string_literal: true

require 'spec_helper'

describe 'kueyen01.ls.lsst.org', :site do
  alma8 = FacterDB.get_facts({ operatingsystem: 'AlmaLinux', operatingsystemmajrelease: '8' }).first
  # rubocop:disable Naming/VariableNumber
  { 'almalinux-8-x86_64': alma8 }.each do |os, facts|
    # rubocop:enable Naming/VariableNumber
    context "on #{os}" do
      let(:facts) { override_facts(facts, fqdn: 'kueyen01.ls.lsst.org') }
      let(:node_params) do
        {
          role: 'rke',
          site: 'ls',
          cluster: 'kueyen',
        }
      end
      let(:vlan_id) { 2301 }
      let(:rt_id) { vlan_id }

      include_context 'with nm interface'

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_class('profile::core::sysctl::rp_filter').with_enable(false)
      end

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'kueyen' => {
              'group' => 'kueyen',
              'member' => 'kueyen[01-03]',
            },
          },
        )
      end

      it do
        is_expected.to contain_class('profile::core::rke').with(
          enable_dhcp: true,
          version: '1.3.12',
        )
      end

      it do
        is_expected.to contain_class('cni::plugins').with(
          version: '1.2.0',
          checksum: 'f3a841324845ca6bf0d4091b4fc7f97e18a623172158b72fc3fdcdb9d42d2d37',
          enable: ['macvlan'],
        )
      end

      it { is_expected.to have_network__interface_resource_count(0) }
      it { is_expected.to have_profile__nm__connection_resource_count(6) }

      %w[
        em1
        em2
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with ens2f1' do
        let(:interface) { 'ens2f1' }

        it_behaves_like 'nm named interface'
        it_behaves_like 'nm dhcp interface'
        it { expect(nm_keyfile['connection']['type']).to eq('ethernet') }
        it { expect(nm_keyfile['connection']['autoconnect']).to be true }
      end

      context 'with ens2f0' do
        let(:interface) { 'ens2f0' }

        it_behaves_like 'nm named interface'
        it { expect(nm_keyfile['connection']['type']).to eq('ethernet') }
        it { expect(nm_keyfile['connection']['autoconnect']).to be false }
      end

      context 'with ens2f0.2301' do
        let(:interface) { 'ens2f0.2301' }

        it_behaves_like 'nm named interface'
        it { expect(nm_keyfile['connection']['type']).to eq('vlan') }
        it { expect(nm_keyfile['connection']['autoconnect']).to be_nil }
        it { expect(nm_keyfile['connection']['master']).to eq('br2301') }
        it { expect(nm_keyfile['connection']['slave-type']).to eq('bridge') }
      end

      context 'with br2301' do
        let(:interface) { 'br2301' }

        it_behaves_like 'nm named interface'
        it { expect(nm_keyfile['connection']['type']).to eq('bridge') }
        it { expect(nm_keyfile['connection']['autoconnect']).to be_nil }
        it { expect(nm_keyfile['bridge']['stp']).to be false }
        it { expect(nm_keyfile['ipv4']['method']).to eq('auto') }
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
      end
    end # on os
  end # on_supported_os
end
