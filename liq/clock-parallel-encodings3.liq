#!./liquidsoap
s = single("video.mkv")
output.file(%theora, "/tmp/a.ogv", s)
clock(output.file(fallible=true, %theora, "/tmp/b.ogv", buffer(s)))
