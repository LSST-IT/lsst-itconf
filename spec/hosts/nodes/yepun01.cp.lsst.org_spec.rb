# frozen_string_literal: true

require 'spec_helper'

describe 'yepun01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'Super Server',
                              },
                              'board' => {
                                'product' => 'H12SSL-NT',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'rke',
          site: 'cp',
          cluster: 'yepun',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'docker', docker_version: '24.0.9'
      include_examples 'baremetal'
      include_context 'with nm interface'
      include_examples 'ceph cluster'

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'yepun' => {
              'group' => 'yepun',
              'member' => 'yepun[01-05]',
            },
          }
        )
      end

      it do
        is_expected.to contain_class('rke').with(
          version: '1.6.5',
          checksum: '80694373496abd5033cb97c2512f2c36c933d301179881e1d28bf7b78efab3e7'
        )
      end

      it { is_expected.to have_nm__connection_resource_count(0) }
    end # on os
  end # on_supported_os
end
