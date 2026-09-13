#!./liquidsoap
s = sequence([sine(duration=5.), sine(500.)])
s = amplify(0.5, s)
# header
def f(a, b)
  if a.db_level > -15. and b.db_level > -15. then
    sequence([a.source, b.source])
  elsif b.db_level > -15. then
    add(normalize=false, [fade.out(a.source), b.source])
  else
    add(normalize=false, [fade.out(a.source), fade.in(b.source)])
  end
end
s = cross(f, s)
# footer
output(s)
