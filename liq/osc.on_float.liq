#!./liquidsoap
s = playlist("~/Music")
# header
v = ref(1.)
osc.on_float("/volume", fun (x) -> v := x)
s = amplify(v, s)
# footer
output(s)
