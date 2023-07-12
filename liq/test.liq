#!./liquidsoap
def handler(request)
  http.response(data="Request: #{request}")
end
harbor.http.register.simple("/test", handler)
output.dummy(sine())
