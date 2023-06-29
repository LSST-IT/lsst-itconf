# frozen_string_literal: true

require 'spec_helper'

describe 'dns1.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(facts,
                       fqdn: 'dns1.tu.lsst.org',
                       is_virtual: true,
                       dmi: {
                         'product' => {
                           'name' => 'KVM',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'dnscache',
          site: 'tu',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'vm'
      include_context 'with nm interface'
      it { is_expected.to have_network__interface_resource_count(0) }
      it { is_expected.to have_profile__nm__connection_resource_count(1) }

      context 'with ens3' do
        let(:interface) { 'ens3' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('140.252.146.71/27,140.252.146.65') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('140.252.146.71;140.252.146.72;140.252.146.73;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('tu.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
      end
    end # on os
  end # on_supported_os
end
