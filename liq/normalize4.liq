#!./liquidsoap
s = playlist("~/Music")
s = normalize(s)
s = source.run(s, every=1., {print("r: #{s.rms()} g: #{s.gain()}")})
output(s)
