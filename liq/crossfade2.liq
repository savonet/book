#!./liquidsoap
s = amplify(0.5, sequence([sine(duration=5.), sine(500.)]))
# header
s = crossfade(fade_out=2., fade_in=3., duration=4., s)
# footer
output(s)
