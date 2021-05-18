#!./liquidsoap
s = sequence([sine(duration=5.), sine(500.)])
s = amplify(0.5, s)
def f(a, b)
  add(normalize=false, [fade.out(a.source), fade.in(b.source)])
end
s = cross(f, s)
output(s)
