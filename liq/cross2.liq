#!./liquidsoap
s = sequence([sine(duration=5.), sine(500.)])
s = amplify(0.5, s)
def f(_, _, _, _, a, b)
  sequence([a, b])
end
s = cross(f, s)
output(s)
