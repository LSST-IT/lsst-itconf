# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::auxtelmcm' do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      include_examples 'auxtelmcm'
    end
  end
end
