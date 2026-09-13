#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%opus(bytes_per_page=1024)
# footer
, "/tmp/out", s)
