# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-mcm.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
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
          role: 'ccs-mcm',
          site: 'tu',
          cluster: 'auxtel-ccs',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(3) }

      context 'with enp5s0f0' do
        let(:interface) { 'enp5s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with enp5s0f1' do
        let(:interface) { 'enp5s0f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm bridge slave interface', master: 'dds'
      end

      context 'with dds' do
        let(:interface) { 'dds' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm bridge interface'
        it_behaves_like 'nm manual interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('140.252.147.20/28') }
        it { expect(nm_keyfile['ipv4']['route1']).to eq('140.252.147.48/28,140.252.147.17') }
        it { expect(nm_keyfile['ipv4']['route2']).to eq('140.252.147.128/27,140.252.147.17') }
      end

      it { is_expected.to contain_class('Ccs_software::Service') }
      it { is_expected.to contain_service('cluster-monitor') }
      it { is_expected.to contain_service('lockmanager') }
      it { is_expected.to contain_service('mmm') }
    end # on os
  end # on_supported_os
end
