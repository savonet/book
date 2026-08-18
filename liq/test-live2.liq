#!./liquidsoap
live    = source.available(sine(), {time.up() mod 10. >= 5.})
pl      = playlist("~/Music")
radio   = fallback([live.{track_sensitive = false}, pl])
output(radio)
