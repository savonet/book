#!./liquidsoap
log.level.set(4)
s = single("test.mp3")
s = replaygain(s)
s.on_track(fun (m) -> print("*** Replaygain of #{m['title']}: #{m['replaygain_track_gain']}"))
output(s)
