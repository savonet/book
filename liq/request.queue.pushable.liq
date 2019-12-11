#!./liquidsoap
playlist = playlist("~/Music")
let (push, queue) = request.queue.pushable()
radio = fallback([queue, playlist])
thread.run({push(request.create("say:A new minute has passed!"))})
out(radio)