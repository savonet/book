#!./liquidsoap
live = source.available(sine(), {time() mod 5. <= 1.})
emergency = chop(every=2., sine(880.))
music = playlist("~/Music")
music = fallback([music, emergency])
music.on_leave(music.skip)
radio = fallback(track_sensitive=false, [live, music])
output(radio)
