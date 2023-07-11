#!./liquidsoap
default = playlist("~/Music")
queue   = request.queue()
radio   = fallback(track_sensitive=false, [queue, default])
def on_request()
  fname = string.trim(file.contents("to-play"))
  log.important("Playing #{fname}.")
  queue.push.uri(fname)
end
file.write(data=string(time()), "to-play")
file.watch("to-play", on_request)
output(radio)
thread.run(delay=2., {log.important("touching"); file.write(data="test.mp3", "to-play")})
