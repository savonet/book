#!./liquidsoap
s = playlist("~/Music")
s = delay_line(10., s)
output(s)
