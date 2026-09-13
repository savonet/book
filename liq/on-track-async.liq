#!./liquidsoap
s = playlist("~/Music")
# header
s.on_track(synchronous=false, fun(m) ->
  ignore(http.post("http://api.example.com/now-playing",
                   data=metadata.json.stringify(m)))
)
