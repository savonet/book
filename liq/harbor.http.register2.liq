#!./liquidsoap
def answer(~protocol, ~headers, ~data, uri)
  http.response(content_type="text/html",
    data="<html><body><h1>It works!</h1></body></html>")
end
harbor.http.register("/test", answer)
output.dummy(blank())
