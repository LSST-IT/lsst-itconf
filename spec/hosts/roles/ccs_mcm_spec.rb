# frozen_string_literal: true

require 'spec_helper'

role = 'ccs-mcm'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      %w[
        comcam-ccs
        auxtel-ccs
      ].each do |cluster|
        context "#{cluster} cluster" do
          lsst_sites.each do |site|
            describe "#{role}.#{site}.lsst.org", :sitepp do
              let(:node_params) do
                {
                  role:,
                  site:,
                  cluster:,
                }
              end
              let(:facts) { lsst_override_facts(os_facts) }

              it { is_expected.to compile.with_all_deps }

              include_examples('common', os_facts:, site:)
              include_examples('ccs common', os_facts:)
              include_examples 'x2go packages', os_facts:
            end # host
          end # lsst_sites
        end # cluster
      end # cluster
    end # on os
  end # on_supported_os
end # role
