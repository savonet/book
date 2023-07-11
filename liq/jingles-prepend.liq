#!./liquidsoap
set("log.level", 4)
s = single("test.mp3")
jingle_now = ref(false)
def metadata()
  jingle_now := not jingle_now()
  if jingle_now() then [("jingle","true")] else [] end
end
jingles = playlist("jingles")
s = chop(every=3., metadata=metadata, s)

def insert_jingle(m)
  log.info("Got metadata")
  if m["jingle"] == "true" then
    log.info("Inserting jingle")
    jingles
  else
    source.fail()
  end
end
s = prepend(s, insert_jingle)
output(s)
