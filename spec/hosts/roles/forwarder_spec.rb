# frozen_string_literal: true

require 'spec_helper'

describe 'forwarder role' do
  lsst_sites.each do |site|
    context "with site #{site}", :site, :common do
      let(:node_params) do
        {
          site: site,
          role: 'forwarder',
          cluster: 'comcam-archive',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'lhn sysctls'

      it { is_expected.to contain_package('git') }
    end
  end # site
end # role
