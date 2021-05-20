#!./liquidsoap
default = playlist("~/Music")
queue   = request.queue()
radio   = fallback(track_sensitive=false, [queue, default])
def play(~protocol, ~headers, ~data, uri)
  log.important("Serving uri: #{uri}")
  let (uri, args) = url.split(uri)
  fname = args["file"]
  title = args["title"]
  if file.exists(fname) then
    queue.push.uri("annotate:title=#{string.quote(title)}:#{fname}")
    http.response(data="Request pushed.")
  else
    http.response(code=404, data="Invalid file.")
  end
end
harbor.http.register("/play", play)
thread.run(delay=3., {log.important("Getting url."); ignore(http.get("http://localhost:8000/play?file=test.mp3&title=La%20bohème"))}) output(radio) set("server.telnet", true)