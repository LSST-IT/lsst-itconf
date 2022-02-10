# @summary
#   Set a kernel parameter and reboot system to apply it
#
# @param name
#   Kernel parameter string. E.g.: `systemd.unified_cgroup_hierarchy=0`
#
# @param reboot
#   Whether or not to force a reboot to ensure kernel parameter is set on the running kernel.
#   Defaults to `true`.
#
define profile::util::kernel_param (
  Boolean $reboot = true,
) {
  $message = "set kernel parameter: ${name}"

  kernel_parameter { $name:
    ensure => present,
  }

  if ($reboot) {
    reboot { $name:
      apply     => finished,
      message   => $message,
      when      => refreshed,
      subscribe => Kernel_parameter[$name],
    }
  }
}
