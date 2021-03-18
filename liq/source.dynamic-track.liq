#!./liquidsoap
freq = ref(110.)

def sines()
  print("New source!")
  freq := !freq * 2.
  sine(duration=2., !freq)
end

s = source.dynamic(track_sensitive=true, sines)
output(s)
