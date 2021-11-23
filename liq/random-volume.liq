#!./liquidsoap
settings.frame.duration.set(1.)
s = playlist("~/Music")
s = amplify({random.float()}, s)
output(s)
