#!./liquidsoap
sines = ref([])
s = source.dynamic({add(normalize=false, sines())})
output(s)
def new()
  # Remove finished sines
  sines := list.filter(source.is_ready, sines())
  # Generate a new sine and add it to the list
  s = sine(amplitude=random.float(min=0., max=1.),
           duration=random.float(min=0., max=5.),
           random.float(min=200., max=1000.))
  sines := list.add((s:source), sines())
end
# Add a new sine from time to time
thread.run(every={random.float(min=0., max=2.)}, new)