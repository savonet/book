#!./liquidsoap
s = amplify(0.5, sequence([sine(duration=5.), sine(500.)]))
# header
s = crossfade(s)
# footer
output(s)
