#!./liquidsoap
live    = source.available(sine(), {time.up() mod 10. >= 5.})
pl      = playlist("~/Music")
radio   = fallback(track_sensitive=false, [live, pl])
output(radio)
