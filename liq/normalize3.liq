#!./liquidsoap
s = playlist("~/Music")
# header
log.level := 5
s = normalize(debug=.5, s)
# footer
output(s)
