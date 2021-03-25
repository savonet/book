#!./liquidsoap
log.level.set(5); start = ref(time())
live = source.available(sine(amplitude=0.5, duration=8., 500.), {time() - !start >= 5.}) # wait for 5 seconds before being available
music = sine(amplitude=0.5, 440.)
def f(a, b)
  add(normalize=false, [fade.out(a), fade.in(b)])
end
radio = fallback(track_sensitive=false, transition_length=5.,
                 transitions=[f, f], [live, music])
output(radio)
