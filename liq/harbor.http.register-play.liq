#!./liquidsoap
default = playlist("~/Music")
queue   = request.queue()
radio   = fallback(track_sensitive=false, [queue, default])
def play(~protocol, ~headers, ~data, uri)
  log.important("Serving uri: #{uri}")
  let (uri, args) = url.split(uri)
  file  = args["file"]
  title = args["title"]
  queue.push(request.create(
    "annotate:title=#{string.quote(title)}:#{file}"))
  http.response(data="Request pushed.")
end
harbor.http.register("/play", play)
thread.run(delay=3., {log.important("Getting url."); ignore(http.get("http://localhost:8000/play?file=test.mp3&title=La%20bohème"))}) output(radio) set("server.telnet", true)