#!./liquidsoap
s = playlist("~/Music")
# header
s = chop(every=3.,
         metadata=[("artist", "Tester"), ("title", "Test")], s)
# footer
output(s)
