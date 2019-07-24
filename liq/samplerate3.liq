def samplerate(~samples, ~duration=1.) = samples / duration end
print(samplerate(samples=44100.))
print(samplerate(samples=44100., duration=1.))
