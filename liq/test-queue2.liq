#!./liquidsoap
d = metronome()
q = request.queue()
s = fallback([q.{track_sensitive = false}, d])
output(s)
thread.run(delay=2.,
           {q.push(request.create("synth:frequency=880,duration=3"))})
