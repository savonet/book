#!./liquidsoap
server.telnet()
playlist = playlist("~/Music")
queue    = request.queue()
radio    = fallback([queue.{track_sensitive = false}, playlist])
output(radio)
