#!./liquidsoap
s = normalize(playlist("~/Music"))
s = stereotool(
  library_file="/path/to/stereotool/shared/lib",
  license_key="my_license_key",
  preset="/path/to/preset/file",
  s)
output(s)