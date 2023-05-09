# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-mcm.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
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
          role: 'ccs-mcm',
          site: 'cp',
          cluster: 'auxtel-ccs',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'

      it { is_expected.to contain_class('Ccs_software::Service') }
      it { is_expected.to contain_service('cluster-monitor') }
      it { is_expected.to contain_service('kafka-broker-service') }
      it { is_expected.to contain_service('localdb') }
      it { is_expected.to contain_service('lockmanager') }
      it { is_expected.to contain_service('mmm') }
      it { is_expected.to contain_service('rest-server') }
    end # on os
  end # on_supported_os
end # role
