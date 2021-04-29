#!./liquidsoap
s = playlist("~/Music")
s = mux_video(video=image("test.png"), s)
output.audio_video(s)
