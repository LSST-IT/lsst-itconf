# frozen_string_literal: true

require 'spec_helper'

describe 'love1.tu.lsst.org', :sitepp do
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
          role: 'amor',
          cluster: 'amor',
          site: 'tu',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(3) }

      context 'with enp4s0f0' do
        let(:interface) { 'enp4s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with enp4s0f1' do
        let(:interface) { 'enp4s0f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm bridge slave interface', master: 'dds'
      end

      context 'with dds' do
        let(:interface) { 'dds' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm bridge interface'
        it_behaves_like 'nm manual interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('140.252.147.134/27') }
        it { expect(nm_keyfile['ipv4']['route1']).to eq('140.252.147.16/28,140.252.147.129') }
        it { expect(nm_keyfile['ipv4']['route2']).to eq('140.252.147.48/28,140.252.147.129') }
      end

      it do
        is_expected.to contain_nfs__client__mount('/net/project').with(
          share: 'project',
          server: 'nfs-project.tu.lsst.org',
          atboot: true
        )
      end
    end # on os
  end # on_supported_os
end
