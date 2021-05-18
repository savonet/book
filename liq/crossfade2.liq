#!./liquidsoap
s = amplify(0.5, sequence([sine(duration=5.), sine(500.)]))
s = crossfade(fade_out=2., fade_in=3., duration=4., s)
output(s)
