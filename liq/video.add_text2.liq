#!./liquidsoap
s = single("lf.mp4")
def x() = int(10. * time.up()) end
def y() = int(10. * time.up()) end
s = video.add_text(size=30, speed=0, x=x, y=y, "Hello world!", s)
output.audio_video(s)
