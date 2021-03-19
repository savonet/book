#!./liquidsoap
set("server.telnet", true)
playlist = playlist("~/Music")
queue    = request.queue()
radio    = fallback([queue, playlist])
output(radio)
