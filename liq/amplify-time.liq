#!./liquidsoap
s = playlist("~/Music")
# header
t0 = time()
def a()
  time() - t0
end
s = amplify(a, s)
# footer
output(s)
