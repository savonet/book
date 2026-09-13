#!./liquidsoap
s = single("video.mkv")
output.file(
# header
%ogg(%opus, %theora(bitrate=1000000))
# footer
, "/tmp/out.ogv", s)
