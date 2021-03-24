#!./liquidsoap
log.level.set(5)
s = sequence([sine(duration=5.), sine(500.)])
s = amplify(0.5, s)
def f(pa, pb, ma, mb, a, b)
  add(normalize=false, [fade.out(a), fade.in(b)])
end
s = cross(duration=4., f, s)
output(s)
