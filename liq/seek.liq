#!./liquidsoap
set("decoder.priorities.mad",100)
s = playlist("~/Music")
thread.run(delay=10., every=10., {ignore(s.seek(-10.))})
output(s)
