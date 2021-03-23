#!./liquidsoap
set("log.level", 4)
s = playlist("~/Music")
thread.run(every=10., {s.skip()})

q = request.queue()
def insert_title(m)
  q.push.uri("say:Last song was #{m['title']} by #{m['artist']}")
end
s.on_track(insert_title)
s = fallback([q, s])
output(s)
