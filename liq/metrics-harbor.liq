#!./liquidsoap
s = playlist("~/Music")
s = rms(s)
rms = s.rms
s = lufs(s)
lufs = s.lufs
def webpage(~protocol, ~data, ~headers, uri)
  metrics = {rms = dB_of_lin(rms()), lufs = lufs()}
  data = json_of(metrics)
  http.response(content_type="application/json", data=data)
end
harbor.http.register("/metrics", webpage)
output(s)
