#!./liquidsoap
radio = playlist("~/Music")
radio = insert_metadata(radio)
def set_metadata(~protocol, ~headers, ~data, uri)
  log.important("Serving uri: #{uri}")
  let (uri, args) = url.split(uri)
  radio.insert_metadata(args)
  http.response(data="Done.")
end
harbor.http.register("/set_metadata", set_metadata)
thread.run(delay=3., {log.important("Getting url."); ignore(http.get("http://localhost:8000/set_metadata?title=La%20bohème"))}) output(radio) set("server.telnet", true)
