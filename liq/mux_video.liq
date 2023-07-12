#!./liquidsoap
a = single("test.mp3") v = single("test.mp4")
s = source.mux.video(video=v, a)
output.audio_video(s)
