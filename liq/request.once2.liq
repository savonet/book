#!./liquidsoap
log.level := 5
r = request.create("test.mp3")
s = request.once(r)
# s = once(single("test.mp3"))
s.on_track(fun (m) -> print(metadata.json.stringify(m)))
output(s)
