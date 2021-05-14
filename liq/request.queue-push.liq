#!./liquidsoap
playlist = playlist("~/Music")
q        = request.queue()
radio    = add([q, playlist])
thread.run(every=60., {q.push.uri("say:Another minute has passed!")})
output(radio)
