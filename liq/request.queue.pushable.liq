#!./liquidsoap
playlist = playlist("~/Music")
queue = request.queue()
radio = fallback([queue, playlist])
thread.run({queue.push(request.create("say:A new minute has passed!"))})
out(radio)