#!./liquidsoap
s = playlist("~/Music")
v = ref(1.)
osc.on_float("/volume", fun (x) -> v := x)
s = amplify({!v}, s)
output(s)
