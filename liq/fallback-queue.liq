#!./liquidsoap
queue = request.queue()
playlist = playlist("~/Music")
# header
radio = fallback([queue, playlist])
# footer
output(radio)
