#!./liquidsoap
s = normalize(playlist("~/Music"))
try
s = stereotool(
  library_file="/path/to/stereotool/shared/lib",
  license_key="my_license_key",
  preset="/path/to/preset/file",
  s)
output(s)
catch _ do print("Stereotool library not found") end