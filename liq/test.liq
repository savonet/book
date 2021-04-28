#!./liquidsoap
# sines = ref([])
# s1 = sine(duration=4.)
# s2 = sine(duration=2., 880.)
# sines = ref([blank()])
# sines = ref([sine(duration=0.5)])
# s = source.dynamic({add(normalize=false, !sines)})
# output(s)
output(sine(duration=0.5))
# def new()
  # s = sine(duration=0.5)
  # sines := list.add(s, !sines)
# end
# thread.run(delay=1., new)