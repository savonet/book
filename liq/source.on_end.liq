#!./liquidsoap
s = playlist("~/Music")
q = request.queue()
def speaker(t, m)
  title = m["title"]
  q.push.uri("say:Last song was #{title}")
end
s = source.on_end(delay=10., s, speaker)
s = add([q, s])
output(s)
