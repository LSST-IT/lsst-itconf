# @summary
#   Manages MariaDB package install on auxtel-mcm node.
#
class profile::core::auxtelmcm {
  package { 'mariadb-server':
    ensure => installed,
  }

  service { 'mariadb':
    ensure  => running,
    enable  => true,
    require => Package['mariadb-server'],
  }
}
