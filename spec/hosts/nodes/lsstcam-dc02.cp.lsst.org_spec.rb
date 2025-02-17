# frozen_string_literal: true

require 'spec_helper'

describe 'lsstcam-dc02.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'PowerEdge R6515',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'ccs-dc',
          cluster: 'lsstcam-ccs',
          site: 'cp',
          variant: 'r6515',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'lsstcam-dc.cp'

      include_examples 'baremetal'
      include_context 'with nm interface'

      it { is_expected.not_to contain_service('image-handling') }
      it { is_expected.to have_nm__connection_resource_count(7) }

      %w[
        eno1
        eno2
        ens3f1np1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with ens1f0np0' do
        let(:interface) { 'ens1f0np0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.175.66/26,139.229.175.126') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.160.53;139.229.160.54;139.229.160.55;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('cp.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
      end

      context 'with ens1f1np1' do
        let(:interface) { 'ens1f1np1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.173.133/27,139.229.173.129') }
        it { expect(nm_keyfile['ipv4']['route1']).to eq('172.24.7.0/24,139.229.173.129') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.160.53;139.229.160.54;139.229.160.55;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('cp.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
        it { expect(nm_keyfile['ethernet']['mtu']).to eq(9000) }
      end

      context 'with ens3f0np0' do
        let(:interface) { 'ens3f0np0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm bridge slave interface', master: 'lsst-daq'
        it { expect(nm_keyfile['ethtool']['ring-rx']).to eq(4096) }
        it { expect(nm_keyfile['ethtool']['ring-tx']).to eq(4096) }
      end

      context 'with lsst-daq' do
        let(:interface) { 'lsst-daq' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm bridge interface'
      end
    end # on os
  end # on_supported_os
end
