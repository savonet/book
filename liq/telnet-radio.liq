#!./liquidsoap
server.telnet()
q = request.queue(id="reqs")
p = playlist(id="main", "~/Music")
radio = fallback(track_sensitive=false, [q, p])
output(radio)
server.harbor()