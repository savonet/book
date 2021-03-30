#!./liquidsoap
# log.level.set(5)
s = playlist("~/Music")
s = normalize(s)
g = s.gain
interactive.harbor()
s = compress.multiband.interactive(s)
interactive.persistent("compress2.params")
s = source.run(s, every=1., {print("gain: #{g()}")})
output(s)
# output.file(%wav, "/tmp/out.wav", s)
