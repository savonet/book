#!./liquidsoap
s = sequence([sine(duration=5.), sine(500.)]) ; s = amplify(0.5, s)
jingle = sine(amplitude=0.5,duration=3.,880.)
def f(_, _, _, _, a, b)
  add(normalize=false, [
    fade.out(a),
    sequence([blank(duration=1.), once(jingle)]),
    sequence([blank(duration=2.), fade.in(b)]),
  ])
end
s = cross(duration=7., f, s)
output(s)
