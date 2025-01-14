# @summary
#   Manages the permissions group for rpi USB devices
#
class profile::pi::ttyusb {
  if defined(Class['profile::core::docker']) {
    $group = Class['profile::core::docker']['socket_group']
  } else {
    $group = '70014'
  }

  systemd::udev::rule { '90-tty-usb.rules':
    rules => [
      "KERNEL==\"ttyUSB[0-9]*\", GROUP=\"${group}\", MODE=\"0660\"",
    ],
  }
}
