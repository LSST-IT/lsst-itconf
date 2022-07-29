# frozen_string_literal: true

require 'spec_helper'

role = 'atsdaq'

describe "#{role} role" do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: self.class.description,
        )
      end

      let(:node_params) do
        {
          role: role,
          site: site,
          cluster: 'auxtel-ccs',
        }
      end

      lsst_sites.each do |site|
        describe "auxtel-fp01.#{site}.lsst.org", :site, :common do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          case site
          when 'tu', 'cp'
            include_examples 'lsst-daq client'
          end
          # it { is_expected.to contain_class('ccs_daq') }
          # it { is_expected.to contain_class('daq::daqsdk').with_version('R5-V0.6') }
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
