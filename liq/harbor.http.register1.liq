#!./liquidsoap
# header
def answer(_)
  http.response(content_type="text/plain", data="It works!")
end
harbor.http.register.simple("/test", answer)
# footer
output.dummy(blank())
