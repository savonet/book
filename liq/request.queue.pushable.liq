#!./liquidsoap
playlist = playlist("~/Music")
let (push, queue) = request.queue.pushable()
radio = fallback([queue, playlist])
exec_at({00s}, {push(request.create("say:A new minute has passed!"))})
out(radio)