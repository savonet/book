#!./liquidsoap
s = playlist("~/Music") v = ref(1.)
s = amplify(v, s)
def send_volume()
  osc.send_float(host="1.2.3.4", port=7777, "/volume", v())
end
thread.run(every=1., send_volume)
output(s)
