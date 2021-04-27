#!./liquidsoap
s = playlist("~/Music")
s = chop(every=3.,
         metadata=[("artist", "Tester"), ("title", "Test")], s)
output(s)
