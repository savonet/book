#!./liquidsoap
a = single("video.mkv")
b = single("video.mkv")
output.file(%theora, "/tmp/a.ogv", a)
clock(output.file(%theora, "/tmp/b.ogv", b))
