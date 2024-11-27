# @summary
#   Manages symbolic links for USB serial devices based on their paths.
#
class profile::pi::add_usb {
  file { '/usr/local/bin/add_usb.sh':
    ensure  => file,
    mode    => '0755',
    # lint:ignore:strict_indent
    content => @(ENV),
      #!/bin/bash
      tty_path=$1
      tty_device=$(basename "$tty_path")
      serial_port=$(ls -l /dev/serial/by-path | grep "$tty_device" | awk '{print $9}')
      
      usb_hard_link="undefined"
      case "$serial_port" in
          "platform-fd500000.pcie-pci-0000:01:00.0-usb-0:1.2:1.0-port0")
              usb_hard_link="/dev/ttyUSB_lower_right"
              ;;
          "platform-fd500000.pcie-pci-0000:01:00.0-usb-0:1.1:1.0-port0")
              usb_hard_link="/dev/ttyUSB_upper_right"
              ;;
          "platform-fd500000.pcie-pci-0000:01:00.0-usb-0:1.4:1.0-port0")
              usb_hard_link="/dev/ttyUSB_lower_left"
              ;;
          "platform-fd500000.pcie-pci-0000:01:00.0-usb-0:1.3:1.0-port0")
              usb_hard_link="/dev/ttyUSB_upper_left"
              ;;
      esac
      
      if [ -e "$usb_hard_link" ]; then
          rm "$usb_hard_link"
      fi
      
      ln "$tty_path" "$usb_hard_link"
      | ENV
    # lint:endignore
  }

  systemd::udev::rule { 'add_usb.rules':
    rules => [
      'SUBSYSTEM=="tty", ACTION=="add", RUN+="/usr/local/bin/add_usb.sh \'$devnode\'"',
    ],
  }
}
