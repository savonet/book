#!/usr/bin/env liquidsoap
set("server.telnet", true)
playlist = playlist("~/Music")
queue = request.queue()
radio = fallback([queue, playlist])
out(radio)