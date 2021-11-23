#!./liquidsoap
%include "metrics.liq"
def save_metrics()
  metrics = {rms = dB_of_lin(rms()), lufs = lufs()}
  data = json.stringify(metrics)
  file.write(data=data, "metrics.json")
end
thread.run(every=1., save_metrics)
output(s)
