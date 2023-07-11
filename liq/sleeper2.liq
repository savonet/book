#!./liquidsoap
s = sleeper(delay=1.1, delay_random=.1, sine())
s = buffer.adaptative(s)
output(s)
