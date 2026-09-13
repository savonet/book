#!./liquidsoap
s = playlist("~/Music")
# header
s = normalize(s)
s = source.run(s, every=1., {print("r: #{s.rms()} g: #{s.gain()}")})
# footer
output(s)
