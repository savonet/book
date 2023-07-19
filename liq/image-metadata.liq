#!./liquidsoap
a = playlist("playlist-with-images")
v = image("test.png")
a.on_track(fun(m) -> v := m["image"])
s = source.mux.video(video=mksafe(v), a)
output.audio_video(s)
thread.run(every=5., {a.skip()})
