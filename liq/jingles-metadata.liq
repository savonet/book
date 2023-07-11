#!./liquidsoap
set("log.level", 4)
s = single("test.mp3")
jingle_now = ref(false)
def metadata()
  jingle_now := not jingle_now()
  if jingle_now() then [("jingle","true")] else [] end
end
s = chop(every=3., metadata=metadata, s)

q = request.queue()
def insert_jingle(m)
  log.info("Got metadata")
  if m["jingle"] == "true" then
    log.info("Inserting jingle")
    q.push.uri("jingle.mp3")
  end
end
s.on_track(insert_jingle)
s = fallback(track_sensitive=false, [q, s])
output(s)
