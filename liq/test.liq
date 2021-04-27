#!./liquidsoap
set("decoder.priorities.mad",100)
s = playlist("~/Music")
thread.run(delay=10., every=2., {print("seek"); ignore(s.seek(-2.))})
output(s)
