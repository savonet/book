#!./liquidsoap
set("server.socket", true)
set("server.socket.path", "/tmp/liquidsoap.sock")
playlist = playlist("~/Music")
queue    = request.queue()
radio    = fallback([queue, playlist])
output(radio)
