#!./liquidsoap
log.level.set(5)
s = sequence([sine(duration=5.), sine(500.)])
s = amplify(0.5, s)
s = crossfade(s)
output(s)
