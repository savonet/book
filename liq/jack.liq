#!./liquidsoap
s = mksafe(normalize(playlist("~/Music")))
output.jack(id="my-out", s)
s = buffer(input.jack(id="my-in"))
output(s)
