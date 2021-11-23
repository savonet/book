#!./liquidsoap
server.telnet()
playlist = playlist("~/Music")
queue    = request.queue()
radio    = fallback(track_sensitive=false, [queue, playlist])
output(radio)
