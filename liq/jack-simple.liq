#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.jack(s)
s = input.jack()
output(buffer(s))
