#!./liquidsoap
s = playlist("~/Music")
s = rms(s)
rms = s.rms
s = lufs(s)
lufs = s.lufs
def save_metrics()
  metrics = {rms = dB_of_lin(rms()), lufs = lufs()}
  data = json_of(metrics)
  file.write(data=data, "metrics.json")
end
thread.run(every=1., save_metrics)
output(s)
