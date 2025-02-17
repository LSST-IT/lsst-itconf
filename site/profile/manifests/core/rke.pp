# @summary
#   Common functionality needed by rke on kubernetes nodes.
#
# @param keytab_base64
#   base64 encoded krb5 keytab
#
# @param version
#   Version of rke utility to install
#
class profile::core::rke (
  Optional[Sensitive[String[1]]] $keytab_base64 = undef,
  String                         $version       = '1.6.5',
) {
  include kmod
  require ipa

  $user = 'rke'
  $uid  = 75500

  if $keytab_base64 {
    profile::util::keytab { $user:
      uid           => $uid,
      keytab_base64 => $keytab_base64,
      require       => Class['ipa'], # ipa must be setup to use the rke user
    }
  }

  vcsrepo { "/home/${user}/k8s-cookbook":
    ensure             => present,
    provider           => git,
    source             => 'https://github.com/lsst-it/k8s-cookbook.git',
    keep_local_changes => true,
    user               => $user,
    owner              => $user,
    group              => $user,
    require            => Class['ipa'], # ipa must be setup to use the rke user
  }

  $rke_checksum = $version ? {
    '1.5.12'     => 'f0d1f6981edbb4c93f525ee51bc2a8ad729ba33c04f21a95f5fc86af4a7af586',
    '1.6.2'      => '68608a97432b4472d3e8f850a7bde0119582ea80fbb9ead923cd831ca97db1d7',
    '1.6.5'      => '80694373496abd5033cb97c2512f2c36c933d301179881e1d28bf7b78efab3e7',
    default  => undef,
  }
  unless ($rke_checksum) {
    fail("Unknown checksum for rke version: ${version}")
  }

  class { 'rke':
    version  => $version,
    checksum => $rke_checksum,
  }

  kmod::load { 'br_netfilter': }
  -> sysctl::value { 'net.bridge.bridge-nf-call-iptables':
    value  => 1,
    target => '/etc/sysctl.d/80-rke.conf',
  }
  -> Class['docker']
}
