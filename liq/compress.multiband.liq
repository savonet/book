#!./liquidsoap
s = normalize(playlist("~/Music")) wet = interactive.float("wet", min=0., max=1., 1.) interactive.harbor() s0 = s
compress = compress(attack=100., release=200., threshold=-20.,
                    ratio=6., gain=7.)
s = add(normalize=false, [
  compress(filter.iir.eq.low     (frequency=200.,        s)),
  compress(filter.iir.eq.low_high(low=200., high=800.,   s)),
  compress(filter.iir.eq.low_high(low=800., high=1500.,  s)),
  compress(filter.iir.eq.low_high(low=1500., high=8000., s)),
  compress(filter.iir.eq.high    (frequency=8000.,       s))
])
s = dry_wet(power=true, wet, s0, s) output(s)
