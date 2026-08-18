#!./liquidsoap
server.telnet()
q = request.queue(id="reqs")
p = playlist(id="main", "~/Music")
radio = fallback([q.{track_sensitive = false}, p])
output(radio)
server.harbor()