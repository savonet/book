#!./liquidsoap
%include "metrics.liq"
def save_metrics()
  data = json.stringify(metrics())
  file.write(data=data, "metrics.json")
end
thread.run(every=1., save_metrics)
output(s)
