#!./liquidsoap
# header
s = fallback([
  input.harbor("foo"), input.alsa()
])
# footer
output(s)
