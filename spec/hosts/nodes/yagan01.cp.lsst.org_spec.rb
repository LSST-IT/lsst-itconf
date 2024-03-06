# frozen_string_literal: true

require 'spec_helper'

describe 'yagan01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'yagan01.cp.lsst.org',
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
          role: 'rke',
          site: 'cp',
          cluster: 'yagan',
          variant: '1114s',
          subvariant: '1.01',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'docker', docker_version: '24.0.9'
      include_examples 'baremetal'
      include_context 'with nm interface'

      it do
        is_expected.to contain_class('profile::core::sysctl::rp_filter').with_enable(false)
      end

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'yagan' => {
              'group' => 'yagan',
              'member' => 'yagan[01-20]',
            },
          },
        )
      end

      it do
        is_expected.to contain_class('rke').with(
          version: '1.4.6',
          checksum: '12d8fee6f759eac64b3981ef2822353993328f2f839ac88b3739bfec0b9d818c',
        )
      end

      it do
        is_expected.to contain_class('cni::plugins').with(
          version: '1.2.0',
          checksum: 'f3a841324845ca6bf0d4091b4fc7f97e18a623172158b72fc3fdcdb9d42d2d37',
          enable: ['macvlan'],
        )
      end

      it { is_expected.to contain_class('profile::core::ospl').with_enable_rundir(true) }

      it { is_expected.to have_nm__connection_resource_count(9) }

      %w[
        eno1np0
        eno2np1
        enp5s0f3u2u2c2
        enp1s0f1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with enp1s0f0' do
        let(:interface) { 'enp1s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with enp1s0f1.1201' do
        let(:interface) { 'enp1s0f1.1201' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm vlan interface', id: 1201, parent: 'enp1s0f1'
        it_behaves_like 'nm bridge slave interface', master: 'br1201'
      end

      context 'with br1201' do
        let(:interface) { 'br1201' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm no-ip interface'
        it_behaves_like 'nm bridge interface'
      end

      context 'with enp1s0f1.1800' do
        let(:interface) { 'enp1s0f1.1800' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm vlan interface', id: 1800, parent: 'enp1s0f1'
        it_behaves_like 'nm bridge slave interface', master: 'br1800'
      end

      context 'with br1800' do
        let(:interface) { 'br1800' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm no-ip interface'
        it_behaves_like 'nm bridge interface'
        it { expect(nm_keyfile['ipv4']['route1']).to eq('139.229.180.0/24') }
        it { expect(nm_keyfile['ipv4']['route1_options']).to eq('table=1800') }
        it { expect(nm_keyfile['ipv4']['route2']).to eq('0.0.0.0/0,139.229.180.254') }
        it { expect(nm_keyfile['ipv4']['route2_options']).to eq('table=1800') }
        it { expect(nm_keyfile['ipv4']['routing-rule1']).to eq('priority 100 from 139.229.180.0/26 table 1800') }
      end
    end # on os
  end # on_supported_os
end
