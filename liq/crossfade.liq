#!./liquidsoap
s = amplify(0.5, sequence([sine(duration=5.), sine(500.)]))
s = crossfade(s)
output(s)
