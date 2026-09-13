#!./liquidsoap
radio = playlist("~/Music")
# header
def set_metadata(req)
  log.important("Inserting metadata: #{req.query}")
  radio.insert_metadata(req.query)
  http.response(data="Done.")
end
harbor.http.register.simple("/set_metadata", set_metadata)
# footer
thread.run(delay=3., {log.important("Getting url."); ignore(http.get("http://localhost:8000/set_metadata?title=La%20bohème"))})
output(radio)
server.telnet()
