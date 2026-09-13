#!./liquidsoap
# header
a = playlist("playlist-with-images")
img_path = ref("test.png")
v = image(img_path)
a.on_track(synchronous=true, fun(m) -> img_path := m["image"])
s = source.mux.video(video=mksafe(v), a)
output.audio_video(s)
# footer
thread.run(every=5., {a.skip()})
