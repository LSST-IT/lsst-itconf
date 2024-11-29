# frozen_string_literal: true

shared_examples 'auxtelmcm' do
  it { is_expected.to contain_package('mariadb-server').with_ensure('installed') }

  it {
    is_expected.to contain_service('mariadb').with(
      ensure: 'running',
      enable: true,
      require: 'Package[mariadb-server]'
    )
  }
end
