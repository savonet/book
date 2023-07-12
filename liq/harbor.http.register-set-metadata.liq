#!./liquidsoap
radio = playlist("~/Music")
radio = insert_metadata(radio)
def set_metadata(request)
  log.important("Inserting metadata: #{request.query}")
  radio.insert_metadata(request.query)
  http.response(data="Done.")
end
harbor.http.register.simple("/set_metadata", set_metadata)
thread.run(delay=3., {log.important("Getting url."); ignore(http.get("http://localhost:8000/set_metadata?title=La%20bohème"))}) output(radio) set("server.telnet", true)
