#!./liquidsoap
live_on = ref(false)
live    = source.available(sine(), {!live_on})
pl      = playlist("~/Music")
radio   = fallback(track_sensitive=false, [live, pl])
output(radio)
thread.run(delay=5., every=5., {live_on := not !live_on})
