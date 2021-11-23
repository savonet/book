#!./liquidsoap
s = playlist("~/Music")
log.level.set(5)
s = normalize(debug=.5, s)
output(s)
