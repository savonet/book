#!./liquidsoap
s = normalize(playlist("~/Music")) wet = interactive.float("wet", min=0., max=1., 1.) let compress.multiband = compress.multiband(wet=wet)
s = compress.multiband(s, [
  {frequency=200.,   attack=100., release=200.,
   threshold=-10.,   ratio=4.,    gain=10.},
  {frequency=800.,   attack=100., release=200.,
   threshold=-10.,   ratio=4.,    gain=6.},
  {frequency=1500.,  attack=100., release=200.,
   threshold=-8.,    ratio=4.,    gain=6.},
  {frequency=8000.,  attack=100., release=200.,
   threshold=-6.,    ratio=4.,    gain=6.},
  {frequency=40000., attack=100., release=200.,
   threshold=-4.,    ratio=4.,    gain=6.}
])
interactive.harbor() interactive.persistent("compress.params") output(s)
