#!./liquidsoap
s = single("video.mkv") output.file(
%ogg(%opus, %theora(bitrate=1000000))
, "/tmp/out.ogv", s)
