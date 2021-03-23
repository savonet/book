#!./liquidsoap
set("log.level", 4)
s = single("test.mp3")
jingle_now = ref(false)
def metadata()
  jingle_now := not !jingle_now
  if !jingle_now then [("jingle","true")] else [] end
end
s = chop(duration=3., metadata=metadata, s)

jingles = playlist("jingles")
p = predicate.signal()
def insert_jingle(m)
  log.info("Got metadata")
  if m["jingle"] == "true" then
    log.info("Inserting jingle")
    p.signal()
  end
end
s.on_track(insert_jingle)
s = switch([(p,jingles), ({true},s)])
output(s)
