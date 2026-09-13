#!./liquidsoap
s = single("lf.mp4")
# header
def x() = int(10. * time.up()) end
def y() = int(10. * time.up()) end
s = video.add_text(size=30, speed=0, x=x, y=y, "Hello world!", s)
# footer
output.audio_video(s)
