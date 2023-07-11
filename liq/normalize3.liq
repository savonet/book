#!./liquidsoap
s = playlist("~/Music")
log.level := 5
s = normalize(debug=.5, s)
output(s)
