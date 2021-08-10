# @summary Support for dns auth letsencrypt certs
#
# @example
#   class profile::core::perfsonar {
#     include profile::core::letsencrypt
#     include augeas  # needed by perfsonar
#
#     $fqdn    = $facts['fqdn']
#     $le_root = "/etc/letsencrypt/live/${fqdn}"
#
#     letsencrypt::certonly { $fqdn:
#       plugin      => 'dns-route53',
#       manage_cron => true,
#     } ->
#     class { '::perfsonar':
#       manage_apache      => true,
#       remove_root_prompt => true,
#       ssl_cert           => "${le_root}/cert.pem",
#       ssl_chain_file     => "${le_root}/fullchain.pem",
#       ssl_key            => "${le_root}/privkey.pem",
#     }
#  }
#
# @param certonly
#   Hash of `letsencrypt::certonly` defined types to create.
#   See: https://github.com/voxpupuli/puppet-letsencrypt/blob/master/manifests/certonly.pp
#
# @param aws_credentials
#   `.aws/credentials` format string for aws route53 credentials
class profile::core::letsencrypt (
  Optional[Hash[String, Hash]] $certonly = undef,
  Optional[String] $aws_credentials      = undef,
) {
  include ::letsencrypt
  include ::letsencrypt::plugin::dns_route53

  # XXX https://github.com/voxpupuli/puppet-letsencrypt/issues/230
  ensure_packages(['python2-futures.noarch'])

  if ($certonly) {
    ensure_resources('letsencrypt::certonly', $certonly)
  }

  if ($aws_credentials) {
    file {
      '/root/.aws':
        ensure => directory,
        mode   => '0700',
        backup => false,
        ;
      '/root/.aws/credentials':
        ensure  => file,
        mode    => '0600',
        backup  => false,
        content => $aws_credentials,
        ;
    }

    # aws credentials required by dns_route53 plugin.
    File['/root/.aws/credentials'] -> Letsencrypt::Certonly<| |>
  }
}
