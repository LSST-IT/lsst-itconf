# @summary
#   Install docker
#
# @param version
#   docker version string
#
# @param socket_group
#   gid for docker named pipe
#
# @param storage_driver
#   name of docker storage driver to use
#
# @param versionlock
#   Array of yum::versionlock resources to create
#
class profile::core::docker (
  Optional[String] $version,
  String $socket_group                      = '70014',
  String $storage_driver                    = 'overlay2',
  Optional[Hash[String, Hash]] $versionlock = undef,
) {
  include docker::networks

  class { 'docker':
    overlay2_override_kernel_check => true,  # needed on el7
    package_source                 => 'docker-ce',
    socket_group                   => $socket_group,
    socket_override                => false,
    storage_driver                 => $storage_driver,
    version                        => $version,
  }

  if $versionlock {
    include yum::plugin::versionlock

    ensure_resources('yum::versionlock', $versionlock)
  }

  # allow docker.socket activitation to proceed before sssd is running and the
  # `docker` group can be resolved via IPA.  It is fine to allow the socket be
  # created with a group of `root`  # as dockerd will chgrp the socket to the
  # correct group when it starts up.
  systemd::dropin_file { 'wait-for-docker-group.conf':
    unit    => 'docker.socket',
    # lint:ignore:strict_indent
    content => @(EOS),
      [Socket]
      SocketGroup=root
      | EOS
    # lint:endignore
  }

  # ensure that sssd is running *before* docker.service starts up
  # we can't use systemd::dropin_file here as puppetlabs/docker is directly declaring a file
  # resource for /etc/systemd/system/docker.service.d/ . See:
  # https://github.com/puppetlabs/puppetlabs-docker/blob/5a5b7d79fe2a290573c5207406afe0a2c68282ce/manifests/service.pp#L315
  file { '/etc/systemd/system/docker.service.d/wait-for-docker-group.conf':
    ensure  => file,
    # lint:ignore:strict_indent
    content => @(EOS),
      [Unit]
      After=network-online.target firewalld.service containerd.service sssd.service
      Requires=docker.socket containerd.service sssd.service
      | EOS
    # lint:endignore
  }

  # /etc/docker is normally created by dockerd the first time the service is
  # started.  However, we would like daemon.json to be in place prior to the
  # first startup.
  file { '/etc/docker':
    ensure => directory,
    mode   => '0755',
  }

  file { '/etc/docker/daemon.json':
    ensure  => file,
    mode    => '0644',
    # lint:ignore:strict_indent
    content => @(JSON),
      {
        "live-restore": true
      }
    | JSON
    # lint:endignore
    notify  => Service['docker'],
  }
}
