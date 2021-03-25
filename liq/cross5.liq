#!./liquidsoap
s = sequence([sine(duration=5.), sine(500.)]) ; s = amplify(0.5, s)
jingle = sine(amplitude=0.5,duration=3.,880.)
def f(_, _, ma, mb, a, b)
  if mb["jingle"] == "true" then
    sequence([a, once(jingle), b])
  else
    sequence([a, b])
  end
end
s = cross(f, s)
output(s)
