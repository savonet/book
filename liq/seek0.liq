#!./liquidsoap
s = playlist("~/Music")
thread.run(every=3., {ignore(s.seek(5.))})
output(s)
