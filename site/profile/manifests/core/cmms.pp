# @summary
#   Load letsencrypt into cmms apache
#

class profile::core::cmms (
) {
  include profile::core::letsencrypt

  $master_fqdn  = $facts[fqdn]

  #  Letsencrypt cert path
  $le_root = "/etc/letsencrypt/live/${master_fqdn}"

  file {'/etc/apache2/ssl/appliance/appliance.openmaint.org.crt':
    ensure => file,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source => "file://${le_root}/fullchain.pem",
    notify => Service['apache2'],
  }

  file {'/etc/apache2/ssl/appliance/appliance.openmaint.org.key':
    ensure => file,
    mode   => '0600',
    owner  => 'root',
    group  => 'root',
    source => "file://${le_root}/privkey.pem",
    notify => Service['apache2'],
  }

  service { 'apache2':
    ensure => 'running',
    enable => true,
  }
}
