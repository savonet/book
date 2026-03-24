#!./liquidsoap
s = single("video.mkv")
output.file(%theora, "/tmp/a.ogv", s)
b = buffer(s)
clock.assign_new([b])
output.file(fallible=true, %theora, "/tmp/b.ogv", b)
