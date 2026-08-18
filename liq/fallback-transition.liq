#!./liquidsoap
log.level := 5; start = ref(time())
live = source.available(sine(amplitude=0.5, duration=5.), {time.up() >= 5.}) # wait for 5 seconds before being available
music = playlist("~/Music")
def to_live({starting})
  add(normalize=false, [
      once(single("say:And now the live show!")),
      fade.in(duration=4., type="sin", starting)
    ])
end
def to_music({starting})
  sequence([(single("jingle.mp3"):source), starting])
end
radio = fallback([live.{track_sensitive = false, on_select = to_live},
                  music.{on_select = to_music}])
output(radio)
