#!./liquidsoap
s = playlist("~/Music")
v = ref(0.)
s.on_frame(synchronous=true, {v := v() + 0.01})
s = amplify(v, s)
output(s)
