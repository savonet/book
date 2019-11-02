#!/usr/bin/env liquidsoap
def mksafe(s)
  fallback(track_sensitive=false, [s, blank()])
end
