#!./liquidsoap
def answer(request)
  data = "We are serving #{request.path}."
  http.response(content_type="text/plain", data=data)
end
harbor.http.register.simple.regexp(regexp("/test.*"), answer)
output.dummy(blank())
