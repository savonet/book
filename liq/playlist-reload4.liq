#!./liquidsoap
# header
s = playlist("playlist")
thread.run(every=3600., {s.reload()})
# footer
output(s)
