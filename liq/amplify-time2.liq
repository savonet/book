#!./liquidsoap
s = playlist("~/Music")
t0 = time()
s = amplify({time() - t0}, s)
output(s)
