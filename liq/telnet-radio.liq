#!./liquidsoap
# header
server.telnet()
q = request.queue(id="reqs")
p = playlist(id="main", "~/Music")
radio = fallback([q.{track_sensitive = false}, p])
output(radio)
# footer
server.harbor()
