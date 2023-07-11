#!./liquidsoap
settings.frame.duration := 1.
s = playlist("~/Music")
s = amplify({random.float()}, s)
output(s)
