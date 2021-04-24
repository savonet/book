#!./liquidsoap
s = playlist("~/Music")
s = bpm(s)
thread.run(every=1., {print("BPM: #{s.bpm()}")})
output(s)
