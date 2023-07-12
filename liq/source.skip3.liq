#!./liquidsoap
s = playlist("~/Music")
def skipper(_)
  s.skip()
  http.response(data="The current song was skipped!")
end
harbor.http.register.simple(port=8000, "/skip", skipper)
output(s)
