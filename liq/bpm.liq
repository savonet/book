#!./liquidsoap
s = playlist("~/Music")
s = bpm(s)
s = source.run(s, every=1., {print("BPM: #{s.bpm()}")})
output(s)
