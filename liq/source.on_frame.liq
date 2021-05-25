#!./liquidsoap
s = playlist("~/Music")
v = ref(0.)
s = source.on_frame(s, {v := !v + 0.01})
s = amplify({!v}, s)
output(s)
