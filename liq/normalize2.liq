#!./liquidsoap
log.level.set(5)
s = playlist("~/Music")
s = normalize(window=4., lookahead=2., down=.5, debug=.5, s)
output(s)
