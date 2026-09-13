#!/usr/bin/env liquidsoap
# header
def check(r)
  fname = request.uri(r)
  string.contains(suffix=".mp3", fname)
end
s = playlist(check_next=check, "~/Music")
# footer
output(s)
