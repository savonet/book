#!./liquidsoap
live = source.available(sine(), {time() mod 5. <= 1.})
emergency = chop(every=2., sine(880.))
music = playlist(conservative=true, "~/Music")
music = fallback([music, emergency])
radio = fallback.skip(live, fallback=music)
output(radio)
