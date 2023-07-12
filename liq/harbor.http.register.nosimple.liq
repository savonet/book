#!./liquidsoap
def answer(request, response)
  response.content_type("text/plain; charset=UTF-8")
  response.data("It works!")
end
harbor.http.register("/test", answer)
output.dummy(blank())
