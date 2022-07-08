# frozen_string_literal: true

require 'spec_helper'

describe 'test1.dev.lsst.org', :site do
  describe 'rke role' do
    lsst_sites.each do |site|
      context "with site #{site}" do
        let(:node_params) do
          {
            site: site,
            role: 'rke',
            ipa_force_join: false, # easy_ipa
          }
        end

        it { is_expected.to compile.with_all_deps }

        include_examples 'debugutils'

        it { is_expected.to contain_class('profile::core::rke') }
      end
    end # site

    context 'with antu cluster', :lhn_node do
      let(:node_params) do
        {
          site: 'ls',
          role: 'rke',
          cluster: 'antu',
          ipa_force_join: false, # easy_ipa
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'debugutils'

      it { is_expected.to contain_class('profile::core::rke') }
    end
  end # role
end
