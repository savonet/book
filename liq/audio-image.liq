#!./liquidsoap
s = playlist("~/Music")
s = source.mux.video(video=image("test.png"), s)
output.audio_video(s)
