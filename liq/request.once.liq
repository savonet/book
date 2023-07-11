#!./liquidsoap
log.level := 5
r = request.once(request.create("ad.mp3"))
s = fallback([r, sine(220.)])
output(s)
