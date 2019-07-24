def samplerate(~samples, ~duration) = samples / duration end
print(samplerate(samples=110250., duration=2.5))
print(samplerate(duration=2.5, samples=110250.))
