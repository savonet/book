#!./liquidsoap
s = sequence([sine(duration=5.), sine(500.)])
s = amplify(0.5, s)
def f(a, b)
  sequence([a.source, b.source])
end
s = cross(f, s)
output(s)
