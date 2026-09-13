#!./liquidsoap
queue = request.queue()
playlist = playlist("~/Music")
# header
radio = fallback([queue.{track_sensitive = false}, playlist])
# footer
output(radio)
