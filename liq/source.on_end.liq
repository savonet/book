#!./liquidsoap
s = playlist("~/Music")
q = request.queue()
def speaker(t, m)
  title = m["title"]
  q.push.uri("say:Last song was #{title}")
end
s.on_position(remaining=true, position=10., synchronous=false, speaker)
s = add([q, s])
output(s)
