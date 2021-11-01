# @summary
#   auxtel-archiver /data path hierarchy
#
class profile::archive::data::auxtel (
  Optional[Hash[String, Hash]] $files = undef,
) {
  if $files {
    ensure_resources('file', $files)
  }
}
