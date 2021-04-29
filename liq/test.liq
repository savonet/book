#!./liquidsoap
# log.level.set(5)
s = playlist("~/Music")
s = mux_video(video=blank(), s)
s = video.add_text.native(color=0xff00ff, speed=0, x=50, y=50, {"Hello\nworld!"}, s)
output.audio_video(s)
