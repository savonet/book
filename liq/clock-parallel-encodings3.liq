#!./liquidsoap
s = single("video.mkv")
output.file(%theora, "/tmp/a.ogv", s)
output.file(fallible=true, %theora, "/tmp/b.ogv", clock(buffer(s)))
