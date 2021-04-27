#!./liquidsoap
s = single("video.mkv")
clock(output.file(%theora, "/tmp/a.ogv", s))
clock(output.file(%theora, "/tmp/b.ogv", s))
