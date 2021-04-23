#!./liquidsoap
set("server.telnet", true)
radio = fallback(track_sensitive=false,
          [request.queue(id="reqs"), playlist(id="main", "~/Music")])
output(radio)
server.harbor()