#!./liquidsoap
# log.level.set(5)
s = playlist("~/Music")
s = normalize(s)
g = s.gain
interactive.harbor()
s = compress.multiband.interactive([200.,800.,1500.,4000.,40000.], s)
interactive.persistent("compress.params")
s = source.run(s, every=1., {print("gain: #{g()}")})
output(s)
# output.file(%wav, "/tmp/out.wav", s)
