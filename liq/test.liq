#!./liquidsoap
def handler(_, response)
  response.content_type("text; charset=UTF-8")
  response.data("This is my answer!")
end
harbor.http.register(port=8000, method="GET", "/test.*", handler)
output.dummy(sine())
