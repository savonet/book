#!./liquidsoap
s = playlist("~/Music")
t0 = time()
def a()
  time() - t0
end
s = amplify(a, s)
output(s)
