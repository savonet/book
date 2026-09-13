#!./liquidsoap
s = playlist("~/Music")
# header
t0 = time()
s  = amplify({time() - t0}, s)
# footer
output(s)
