#!./liquidsoap
s = sequence([sine(duration=5.), sine(500.)]) ; s = amplify(0.5, s)
jingle = sine(amplitude=0.5,duration=3.,880.)
# header
def f(a, b)
  if b.metadata["jingle"] == "true" then
    sequence([a.source, (once(jingle):source), b.source])
  else
    sequence([a.source, b.source])
  end
end
# footer
s = cross(f, s)
output(s)
