#!./liquidsoap
def answer(~protocol, ~headers, ~data, uri)
  http.response(content_type="text/plain", data="It works!")
end
harbor.http.register("/test", answer)
output.dummy(blank())
