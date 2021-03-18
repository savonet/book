#!./liquidsoap
freq = ref(110.)
last = ref(time())

def sines()
  if (time() - !last) < 1. then null() else
    freq := !freq * 2.
    last := time()
    null(sine(!freq))
  end
end

s = source.dynamic(sines)
output(s)
