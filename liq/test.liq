#!./liquidsoap
set("log.level", 4)
l = playlog()
def check(r)
  m = request.metadata(r)
  if l.last(m) < 3600. then
    log.info("Rejecting #{m['filename']} (played #{l.last(m)}s ago).")
    false
  else
    l.add(m)
    true
  end
end
s = playlist(check_next=check, "playlist")
output(s)
