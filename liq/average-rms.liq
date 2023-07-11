#!./liquidsoap
s = playlist("~/Music")
rmsl = ref([])
s = rms(s)
s = source.run(s, every=0.01, {rmsl := list.add(s.rms(), rmsl())})

def mean_rms()
  r = ref(0.)
  list.iter(fun (x) -> r := r() + x, rmsl())
  r() / float_of_int(list.length(rmsl()))
end

s = source.run(s, every=1., {print("RMS: #{mean_rms()}")})

profiler.enable()
s = source.run(s, every=10., {print("#{profiler.stats.string()}")})
output(s)
