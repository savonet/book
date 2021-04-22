#!./liquidsoap
s = playlist("~/Music")
s = rms(s)
rms = s.rms
s = lufs(s)
lufs = s.lufs
def webpage(~protocol, ~data, ~headers, uri)
  metrics = {rms = dB_of_lin(rms()), lufs = lufs()}
  data = json_of(metrics)
  http.response(data = data)
end
harbor.http.register(port=8000, method="GET", "/metrics", webpage)
output(s)
