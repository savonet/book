#!./liquidsoap
s = sequence([sine(duration=5.), sine(500.)]) ; s = amplify(0.5, s)
jingle = sine(amplitude=0.5,duration=3.,880.)
def f(a, b)
  add(normalize=false, [
    fade.out(a.source),
    sequence([blank(duration=1.), once(jingle)]),
    sequence([blank(duration=2.), fade.in(b.source)]),
  ])
end
s = cross(duration=6., f, s)
output(s)
