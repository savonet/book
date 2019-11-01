#!/usr/bin/env liquidsoap
set("server.telnet", true)
playlist = playlist("~/Music")
queue = request.queue()
radio = fallback(track_sensitive=false, [queue, playlist])
out(radio)