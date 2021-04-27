#!./liquidsoap
s1 = buffer(clock(sleeper(delay=1.5, sine(880.))))
s2 = sine(440.)
s = add([s1,s2])
output(s)
thread.run(every=1., {print(clock.status.seconds())})