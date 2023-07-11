#!./liquidsoap
a = playlist("playlist-with-images")
v = image()
a.on_track(fun(m) -> v := m["image"])
s = mux_video(video=mksafe(v), a)
output.audio_video(s)
thread.run(every=5., {a.skip()})
