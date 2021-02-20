#!./liquidsoap
s = playlist("~/Music")
s = rms(s)
def save_metrics() = file.write(data="RMS: #{s.rms()}", "/tmp/rms") end
thread.run(every=1., save_metrics)
output(s)
