#!/usr/bin/env liquidsoap
s = playlist("~/Music")
def skipper(~protocol, ~data, ~headers, _)
  s.skip()
  http.response(data="The current song was skipped!")
end
harbor.http.register(port=8000, method="GET", "skip", skipper)
output(s)
