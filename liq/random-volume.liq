#!./liquidsoap
# header-a
settings.frame.duration := 1.
# footer-a
# header-b
s = playlist("~/Music")
s = amplify({random.float()}, s)
output(s)
