#!./liquidsoap
set("log.level", 4)
s = single("test.mp3")
jingle_now = ref(false)
def metadata()
  jingle_now := not !jingle_now
  if !jingle_now then [("ad","true")] else [] end
end
s = chop(duration=3., metadata=metadata, s)

q = request.queue()
def insert_ads(m)
  log.info("Got metadata")
  if m["ad"] == "true" then
    log.info("Inserting ad")
    q.push.uri("jingle.mp3")
  end
end
s.on_metadata(insert_ads)
s = fallback(track_sensitive=false, [q, s])
output(s)
