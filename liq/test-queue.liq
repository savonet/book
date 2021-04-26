#!./liquidsoap
d = sine(440.)
q = request.queue()
s = fallback(track_sensitive=false, [q, d])
output(s)
thread.run(delay=2.,
           {q.push(request.create("synth:frequency=880,duration=3"))})
