#!./liquidsoap
s = playlist("~/Music")
def skipper(~protocol, ~headers, ~data, uri)
  s.skip()
  http.response(data="The current song was skipped!")
end
harbor.http.register(port=8000, "skip", skipper)
output(s)
