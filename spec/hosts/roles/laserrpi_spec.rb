# frozen_string_literal: true

require 'spec_helper'

role = 'laserrpi'

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
          let(:facts) do
            lsst_override_facts(os_facts,
                                cpuinfo: {
                                  'processor' => {
                                    'Model' => 'Raspberry Pi 4 Model B Rev 1.2',
                                  },
                                },
                                os: {
                                  'architecture' => 'aarch64',
                                })
          end

          it { is_expected.to compile.with_all_deps }

          include_examples('common', os_facts:, site:)
          include_examples 'docker'
          include_examples('gpio', os_facts:)
          include_examples 'pigpio'
          include_examples 'ttyusb'
          include_examples 'dco'
          include_examples 'add_usb'

          it do
            is_expected.to contain_file('/boot/config.txt').with(
              ensure: 'file',
              mode: '0755',
              content: <<~CONTENT
                [all]
                dtoverlay=disable-bt
                dtparam=audio=on
              CONTENT
            )
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
