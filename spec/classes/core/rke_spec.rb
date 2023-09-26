# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::rke' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) do
        <<~PP
          include docker
          include easy_ipa
          class { 'sssd': service_names => ['sssd'] }
        PP
      end

      context 'with no params' do
        it { is_expected.to compile.with_all_deps }

        include_examples 'rke profile'

        it { is_expected.not_to contain_class('cni::plugins') }
        it { is_expected.not_to contain_class('cni::plugins::dhcp') }

        it do
          is_expected.not_to contain_profile__util__keytab('rke')
            .that_requires('Class[easy_ipa]')
        end

        it do
          is_expected.to contain_class('rke').with(
            version: '1.3.12',
            checksum: '579da2206aec09cadccd8d6f4818861e78a256b6ae550a229335e500a472bd50',
          )
        end
      end

      context 'with enable_dhcp param' do
        context 'when false' do
          let(:params) do
            {
              enable_dhcp: false,
            }
          end

          it { is_expected.to compile.with_all_deps }

          include_examples 'rke profile'

          it { is_expected.not_to contain_class('cni::plugins') }
          it { is_expected.not_to contain_class('cni::plugins::dhcp') }
        end

        context 'when true' do
          let(:params) do
            {
              enable_dhcp: true,
            }
          end

          it { is_expected.to compile.with_all_deps }

          include_examples 'rke profile'

          it { is_expected.to contain_class('cni::plugins') }
          it { is_expected.to contain_class('cni::plugins::dhcp') }
        end
      end

      context 'with keytab_base64 param' do
        context 'when undef' do
          let(:params) do
            {
              keytab_base64: :undef,
            }
          end

          it { is_expected.to compile.with_all_deps }

          include_examples 'rke profile'

          it { is_expected.not_to contain_profile__util__keytab('rke') }
        end

        context 'when 42' do
          let(:params) do
            {
              keytab_base64: sensitive('42'),
            }
          end

          it { is_expected.to compile.with_all_deps }

          include_examples 'rke profile'

          it do
            is_expected.to contain_profile__util__keytab('rke').with(
              uid: 75_500,
              keytab_base64: sensitive('42'),
            )
          end
        end
      end

      context 'with version param' do
        context 'when 1.3.12' do
          let(:params) do
            {
              version: '1.3.12',
            }
          end

          it { is_expected.to compile.with_all_deps }

          include_examples 'rke profile'

          it do
            is_expected.to contain_class('rke').with(
              version: '1.3.12',
              checksum: '579da2206aec09cadccd8d6f4818861e78a256b6ae550a229335e500a472bd50',
            )
          end
        end

        context 'when 42' do
          let(:params) do
            {
              version: '42',
            }
          end

          it { is_expected.to compile.and_raise_error(%r{Unknown checksum for rke version: 42}) }
        end
      end
    end
  end
end
