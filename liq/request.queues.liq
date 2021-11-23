#!./liquidsoap
server.telnet()
playlist = playlist("~/Music")
queue1   = request.queue(id="q1")
queue2   = request.queue(id="q2")
radio    = fallback([queue1, queue2, playlist])
output(radio)
