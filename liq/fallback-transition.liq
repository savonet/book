#!./liquidsoap
log.level.set(5); start = ref(time())
live = source.available(sine(amplitude=0.5, duration=5.), {time.up() >= 5.}) # wait for 5 seconds before being available
music = playlist("~/Music")
def to_live(a, b)
  add(normalize=false, [
      once(single("say:And now the live show!")),
      fade.in(duration=4., type="sin", b)
    ])
end
def to_music(a, b)
  sequence([single("jingle.mp3"), b])
end
radio = fallback(track_sensitive=false, transition_length=5.,
                 transitions=[to_live, to_music], [live, music])
output(radio)
