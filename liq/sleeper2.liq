#!./liquidsoap
s = sleeper(delay=1.1, random=.1, sine())
s = buffer.adaptative(s)
output(s)
