#!/usr/bin/env liquidsoap
def mksafe(s)
  fallback([s.{track_sensitive = false}, blank()])
end
