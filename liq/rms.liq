#!./liquidsoap
s = playlist("~/Music")
s = rms(s)
def print_rms()
  r = dB_of_lin(s.rms())
  log.important("RMS: #{r} dB")
end
thread.run(every=1., print_rms)
output(s)
