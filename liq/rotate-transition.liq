#!./liquidsoap
log.level := 5
s = sine(duration=5.)
m = sine(500.)
def f(a, b)
  add(normalize=false, [fade.out(a), fade.in(b)])
end
s = rotate(transition_length=4., transitions=[f, f], [s, m])
output(s)
output.file(%mp3, "/tmp/out.mp3", s)
