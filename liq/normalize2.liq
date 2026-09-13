#!./liquidsoap
log.level := 5
# header
s = playlist("~/Music")
s = normalize(window=4., down=.5, lookahead=2., debug=.5, s)
# footer
output(s)
