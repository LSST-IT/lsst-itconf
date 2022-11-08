# @summary
#   Manage packages and services needed on different hardware platforms.
class profile::core::hardware {
  # lint:ignore:case_without_default
  case $facts.dig('dmi', 'product', 'name') {
    # XXX add a fact to check /sys/class/ipmi/ instead of white listing specific models
    /PowerEdge/: {
      include ipmi

      if $facts['has_dellperc'] {
        include profile::core::perccli
      }
    }
    /1114S-WN10RT/: {
      include ipmi

      # EL7 only
      if fact('os.family') == 'RedHat' and fact('os.release.major') == '7' {
        # aspm is suspected of causing problems with internal NVMes
        include profile::core::kernel::pcie_aspm
        # apst is suspected of causing problems with NVMes
        include profile::core::kernel::nvme_apst
        # attempt to improve NVMe hotplug support on el7
        profile::util::kernel_param { 'pci=pcie_bus_perf':
          reboot => false,
        }
      }
    }
  }

  # On SM H12SSL-NT dmi.product.name == "Super Server", which isn't very helpful
  case fact('dmi.board.product') {
    /H12SSL-NT/: {
      include ipmi
    }
  }
  # lint:endignore
}
