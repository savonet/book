#!./liquidsoap
# log.level.set(5)
s = playlist("~/Music")
s = normalize(s)
g = s.gain
interactive.harbor()
wet = interactive.float("wet", min=0., max=1., 1.)
s = compress.multiband(wet=wet, s, [
{frequency=200.,   attack=100., release=200., threshold=-10., ratio=4., gain=10.},
{frequency=800.,   attack=100., release=200., threshold=-10., ratio=4., gain=6.},
{frequency=1500.,  attack=100., release=200., threshold=-8., ratio=4., gain=6.},
{frequency=8000.,  attack=100., release=200., threshold=-6., ratio=4., gain=6.},
{frequency=40000., attack=100., release=200., threshold=-4., ratio=4., gain=6.}
])
interactive.persistent("compress.params")
s = source.run(s, every=1., {print("wet: #{wet()}\tgain: #{g()}")})
output(s)
# output.file(%wav, "/tmp/out.wav", s)
