#!/usr/bin/env liquidsoap
def check(r)
  fname = request.filename(r)
  string.contains(suffix=".mp3", fname)
end
s = playlist(check_next=check, "~/Music")
out(s)
