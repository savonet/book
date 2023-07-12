#!./liquidsoap --safe
default = playlist("~/Music")
queue   = request.queue()
radio   = fallback(track_sensitive=false, [queue, default])
def play(request)
  fname = request.query["file"]
  title = request.query["title"]
  log.important("Serving file #{fname} whose title is #{title}.")
  if file.exists(fname) then
    queue.push.uri("annotate:title=#{string.quote(title)}:#{fname}")
    http.response(data="Request pushed.")
  else
    http.response(status_code=404, data="Invalid file.")
  end
end
harbor.http.register.simple("/play", play)
thread.run(delay=3., {log.important("Getting url."); ignore(http.get("http://localhost:8000/play?file=test.mp3&title=La%20bohème"))}) output(radio) set("server.telnet", true)