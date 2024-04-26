# frozen_string_literal: true

require 'spec_helper'

role = 'htcondor'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) { os_facts }
      let(:node_params) do
        {
          role: role,
          site: site,
        }
      end

      lsst_sites.each do |site|
        next if site == 'tu'

        fqdn = "#{role}.#{site}.lsst.org"
        override_facts(os_facts, fqdn: fqdn, networking: { 'fqdn' => fqdn })

        describe fqdn, :sitepp do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          %w[
            profile::core::common
            profile::core::nfsclient
            htcondor
          ].each do |c|
            it { is_expected.to contain_class(c) }
          end

          it { is_expected.to contain_package('nano') }

          it do
            is_expected.to contain_file('/etc/profile.d/rubin.sh').with(
              ensure: 'file',
              mode: '0600',
              content: 'export DAF_BUTLER_REPOSITORY_INDEX=/project/data-repos.yaml',
            )
          end

          it { is_expected.to contain_class('htcondor').with_htcondor_version('23.0') }

          it { is_expected.to contain_yumrepo('condor') }

          it do
            is_expected.to contain_package('condor')
              .that_requires('Yumrepo[condor]')
          end

          it { is_expected.to contain_file('/etc/condor/condor_config.local') }

          it { is_expected.to contain_file('/etc/condor/config.d/schedd').with_content(%r{^DAEMON_LIST = MASTER, SCHEDD}) }

          it do
            is_expected.to contain_service('condor').with(
              ensure: 'running',
              enable: true,
            )
          end

          if site == 'dev'
            it { is_expected.to contain_class('htcondor').with_htcondor_host('htcondor-cm.dev.lsst.org') }
          end

          if %w[ls dev].include?(site)
            it do
              is_expected.to contain_nfs__client__mount('/rsphome').with(
                share: 'rsphome',
                server: 'nfs-rsphome.ls.lsst.org',
                atboot: true,
              )
            end

            it do
              is_expected.to contain_nfs__client__mount('/project').with(
                share: 'project',
                server: 'nfs-project.ls.lsst.org',
                atboot: true,
              )
            end
          end

          if site == 'ls'
            it { is_expected.to contain_class('htcondor').with_htcondor_host('htcondor-cm.ls.lsst.org') }

            it do
              is_expected.to contain_nfs__client__mount('/repo/LATISS').with(
                share: '/auxtel/repo/LATISS',
                server: 'nfs-auxtel.ls.lsst.org',
                atboot: true,
              )
            end

            it do
              is_expected.to contain_nfs__client__mount('/data/lsstdata/BTS/auxtel').with(
                share: '/auxtel/lsstdata/BTS/auxtel',
                server: 'nfs-auxtel.ls.lsst.org',
                atboot: true,
              )
            end

            it do
              is_expected.to contain_nfs__client__mount('/datasets').with(
                share: 'lsstdata',
                server: 'nfs-lsstdata.ls.lsst.org',
                atboot: true,
              )
            end
          end

          if site == 'cp'
            it { is_expected.to contain_class('htcondor').with_htcondor_host('htcondor-cm.cp.lsst.org') }

            it do
              is_expected.to contain_nfs__client__mount('/rsphome').with(
                share: 'rsphome',
                server: 'nfs-rsphome.cp.lsst.org',
                atboot: true,
              )
            end

            it do
              is_expected.to contain_nfs__client__mount('/project').with(
                share: 'project',
                server: 'nfs1.cp.lsst.org',
                atboot: true,
              )
            end

            it do
              is_expected.to contain_nfs__client__mount('/repo/LATISS').with(
                share: '/auxtel/repo/LATISS',
                server: 'nfs-auxtel.cp.lsst.org',
                atboot: true,
              )
            end

            it do
              is_expected.to contain_nfs__client__mount('/repo/LSSTComCam').with(
                share: '/repo/LSSTComCam',
                server: 'comcam-archiver.cp.lsst.org',
                atboot: true,
              )
            end

            it do
              is_expected.to contain_nfs__client__mount('/readonly/lsstdata/other').with(
                share: 'lsstdata',
                server: 'nfs1.cp.lsst.org',
                atboot: true,
              )
            end

            it do
              is_expected.to contain_nfs__client__mount('/readonly/lsstdata/comcam').with(
                share: 'lsstdata',
                server: 'comcam-archiver.cp.lsst.org',
                atboot: true,
              )
            end

            it do
              is_expected.to contain_nfs__client__mount('/readonly/lsstdata/auxtel').with(
                share: '/auxtel/lsstdata',
                server: 'nfs-auxtel.cp.lsst.org',
                atboot: true,
              )
            end
          end
        end
      end # host
    end # on os
  end # on_supported_os
end # role
