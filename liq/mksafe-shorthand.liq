#!./liquidsoap
s = input.http("http://...")
# header
s = mksafe(s)
# footer
output(s)
