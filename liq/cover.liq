#!./liquidsoap
a = playlist("~/Music")
s = mux_video(video=mksafe(video.cover(a)), a)
output.audio_video(s)
thread.run(every=5., a.skip)