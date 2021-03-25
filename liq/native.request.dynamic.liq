#!./liquidsoap
files = ref(list.shuffle(playlist.files("~/Music")))
def next_song()
  f = list.hd(!files)
  files := list.tl(!files)
  print("Next song: #{f}")
  request.create(f)
end
s = native.request.dynamic(next_song)
s = skipper(every=5., s)
# thread.run(every=5., {s.skip()})
radio = fallback([s, chop(duration=2., sine(amplitude=.5, 220.))])
output(radio)
