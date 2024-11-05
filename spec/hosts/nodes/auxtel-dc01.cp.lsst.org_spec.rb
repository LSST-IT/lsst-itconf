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

      it do
        is_expected.to contain_s3daemon__instance('cp-latiss').with(
          s3_endpoint_url: 'https://s3.cp.lsst.org',
          port: 15_570,
          image: 'ghcr.io/lsst-dm/s3daemon:sha-e117c22'
        )
      end

      it do
        is_expected.to contain_s3daemon__instance('s3dfrgw-latiss').with(
          s3_endpoint_url: 'https://s3dfrgw.slac.stanford.edu',
          port: 15_580,
          image: 'ghcr.io/lsst-dm/s3daemon:sha-e117c22'
        )
      end

      include_examples 'baremetal'

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
    end # on os
  end # on_supported_os
end # role
