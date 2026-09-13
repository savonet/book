#!./liquidsoap
# header
a = playlist("~/Music")
s = source.mux.video(video=mksafe(video.cover(a)), a)
output.audio_video(s)
# footer
thread.run(every=5., a.skip)
