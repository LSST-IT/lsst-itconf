# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-mcm.ls.lsst.org', :site do
  alma8 = FacterDB.get_facts({ operatingsystem: 'AlmaLinux', operatingsystemmajrelease: '8' }).first
  # rubocop:disable Naming/VariableNumber
  { 'almalinux-8-x86_64': alma8 }.each do |os, facts|
    # rubocop:enable Naming/VariableNumber
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'auxtel-mcm.ls.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'atsccs',
          site: 'ls',
          cluster: 'auxtel-ccs',
        }
      end

      let(:alert_email) do
        'base-teststand-alerts-aaaai5j4osevcaaobtog67nxlq@lsstc.slack.com'
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'ccs alerts'
      include_context 'with nm interface'

      it { is_expected.to have_network__interface_resource_count(0) }
      it { is_expected.to have_profile__nm__connection_resource_count(7) }

      %w[
        eno1np0
        eno2np1
        enp4s0f3u2u2c2
        enp129s0f1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with enp129s0f0' do
        let(:interface) { 'enp129s0f0' }

        it_behaves_like 'nm named interface'
        it_behaves_like 'nm dhcp interface'
        it { expect(nm_keyfile['connection']['type']).to eq('ethernet') }
        it { expect(nm_keyfile['connection']['autoconnect']).to be_nil }
      end

      context 'with enp129s0f1.2502' do
        let(:interface) { 'enp129s0f1.2502' }

        it_behaves_like 'nm named interface'
        it { expect(nm_keyfile['connection']['type']).to eq('vlan') }
        it { expect(nm_keyfile['connection']['autoconnect']).to be_nil }
        it { expect(nm_keyfile['connection']['master']).to eq('dds') }
        it { expect(nm_keyfile['connection']['slave-type']).to eq('bridge') }
      end

      context 'with dds' do
        let(:interface) { 'dds' }

        it_behaves_like 'nm named interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm bridge interface'
      end

      it { is_expected.to contain_package('OpenSpliceDDS') }

      it { is_expected.to contain_file('/etc/ccs/ccsGlobal.properties').with_content(%r{^org.hibernate.engine.internal.level=WARNING}) }
      it { is_expected.to contain_file('/etc/ccs/ccsGlobal.properties').with_content(%r{^.level=WARNING}) }

      it { is_expected.to contain_file('/etc/ccs/setup-sal5').with_content(%r{^export LSST_DDS_INTERFACE=auxtel-mcm-dds.ls.lsst.org}) }

      it { is_expected.to contain_file('/etc/ccs/setup-sal5').with_content(%r{^export LSST_DDS_PARTITION_PREFIX=base}) }

      it { is_expected.to contain_class('Ccs_software::Service') }
      it { is_expected.to contain_service('mmm') }
      it { is_expected.to contain_service('cluster-monitor') }
      it { is_expected.to contain_service('localdb') }
      it { is_expected.to contain_service('rest-server') }

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'misc' => {
              'group' => 'misc',
              'member' => 'auxtel-mcm,auxtel-dc01,auxtel-fp01',
            },
            'all' => {
              'group' => 'all',
              'member' => '@misc',
            },
          },
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/data').with(
          share: 'data',
          server: 'auxtel-fp01.ls.lsst.org',
          atboot: true,
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/repo').with(
          share: 'repo',
          server: 'auxtel-archiver.ls.lsst.org',
          atboot: true,
        )
      end
    end # on os
  end # on_supported_os
end # role
