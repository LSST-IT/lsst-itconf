# frozen_string_literal: true

require 'spec_helper'

describe 'profile::ccs::graphical' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:unwanted_pkgs) do
        %w[
          gnome-initial-setup
          libvirt-daemon
          cockpit
          cockpit-bridge
          cockpit-storaged
          cockpit-ws
          cockpit-packagekit
          cockpit-podman
          cockpit-system
        ]
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'x2go packages', facts: facts

      if facts[:os]['release']['major'] == '7'
        it do
          unwanted_pkgs.each do |pkg|
            is_expected.to contain_yum__group('GNOME Desktop').with(
              ensure: 'present',
              timeout: '1800',
            ).that_notifies("Package[#{pkg}]")
          end
        end

        it do
          is_expected.to contain_yum__group('MATE Desktop').with(
            ensure: 'present',
            timeout: '900',
          )
        end
      else
        it do
          unwanted_pkgs.each do |pkg|
            is_expected.to contain_yum__group('Server with GUI').with(
              ensure: 'present',
              timeout: '900',
            ).that_notifies("Package[#{pkg}]")
          end
        end
      end

      it do
        unwanted_pkgs.each do |pkg|
          is_expected.to contain_package(pkg).with_ensure('purged')
        end
      end
    end
  end
end
