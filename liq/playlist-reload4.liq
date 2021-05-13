#!./liquidsoap
s = playlist("playlist")
thread.run(every=3600., {s.reload()})
output(s)
