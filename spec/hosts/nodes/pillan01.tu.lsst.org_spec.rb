# frozen_string_literal: true

require 'spec_helper'

#
# Testing network interfaces from the pillan cluster hiera layer. One node in
# the pillan cluster should be sufficient.
#
describe 'pillan01.tu.lsst.org', :site do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:int1) do
        if (facts[:os]['family'] == 'RedHat') && (facts[:os]['release']['major'] == '7')
          'eno1'
        else
          'eno1np0'
        end
      end

      let(:int2) do
        if (facts[:os]['family'] == 'RedHat') && (facts[:os]['release']['major'] == '7')
          'eno2d1'
        else
          'eno2np1'
        end
      end

      let(:facts) do
        facts.merge(
          fqdn: 'pillan01.tu.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'rke',
          site: 'tu',
          cluster: 'pillan',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_network__interface(int1).with(
          bootproto: 'none',
          master: 'bond0',
          onboot: 'yes',
          slave: 'yes',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface(int2).with(
          bootproto: 'none',
          master: 'bond0',
          onboot: 'yes',
          slave: 'yes',
          type: 'Ethernet',
        )
      end

      # common between EL7 & EL8
      %w[
        enp129s0f0
        enp129s0f1
      ].each do |int|
        it do
          is_expected.to contain_network__interface(int).with(
            bootproto: 'none',
            master: 'bond0',
            onboot: 'yes',
            slave: 'yes',
            type: 'Ethernet',
          )
        end
      end
    end # on os
  end # on_supported_os
end
