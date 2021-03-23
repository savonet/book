#!./liquidsoap
set("log.level", 4)
s = playlist("~/Music")
thread.run(every=10., {s.skip()})

def insert_title(m)
  single("say:Last song was #{m['title']} by #{m['artist']}")
end
s = append(s, insert_title)
output(s)
