# frozen_string_literal: true

require 'spec_helper'

role = 'auxtel-archiver'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :sitepp do
          let(:node_params) do
            {
              role:,
              site:,
            }
          end
          let(:facts) { lsst_override_facts(os_facts) }

          it { is_expected.to compile.with_all_deps }

          include_examples('common', os_facts:, site:)
          include_examples 'archiver'
          include_examples 'archive data auxtel'

          it { is_expected.to contain_file('/data/repo/LATISS') }
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
