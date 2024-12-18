# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-dc01.cp.lsst.org', :sitepp do
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
          role: 'ccs-dc',
          cluster: 'auxtel-ccs',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(2) }

      %w[
        eno2
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

      it do
        is_expected.to contain_s3daemon__instance('cp-latiss').with(
          s3_endpoint_url: 'https://s3.cp.lsst.org',
          port: 15_570,
          image: 'ghcr.io/lsst-dm/s3daemon:sha-57e1aa9'
        )
      end

      it do
        is_expected.to contain_s3daemon__instance('s3dfrgw-latiss').with(
          s3_endpoint_url: 'https://s3dfrgw.slac.stanford.edu',
          port: 15_580,
          image: 'ghcr.io/lsst-dm/s3daemon:sha-57e1aa9'
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/data').with(
          share: 'data',
          server: 'auxtel-fp01.cp.lsst.org',
          atboot: true
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/repo').with(
          share: 'auxtel/repo',
          server: 'nfs-auxtel.cp.lsst.org',
          atboot: true
        )
      end
    end
  end # on os
end # on_supported_os
