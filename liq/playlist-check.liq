#!/usr/bin/env liquidsoap
def check(r)
  fname = request.uri(r)
  string.contains(suffix=".mp3", fname)
end
s = playlist(check_next=check, "~/Music")
out(s)
