#!./liquidsoap
set("frame.duration", 1.)
s = playlist("~/Music")
s = amplify({random.float()}, s)
output(s)
