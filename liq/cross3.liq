#!./liquidsoap
s = sequence([sine(duration=5.), sine(500.)]) ; s = amplify(0.5, s)
jingle = playlist("jingles")
# header
def f(a, b)
  sequence([a.source, (once(jingle):source), b.source])
end
# footer
s = cross(f, s)
output(s)
