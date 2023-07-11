#!./liquidsoap
log.level := 5
s = playlist("videos")
s = video.add_image(x=10, y=10, width=50, height=50, file="logo.png", s)
output.video(s)