def samplerate(~samples, ~duration) = samples / duration end
# footer
print(samplerate(samples=110250., duration=2.5))
print(samplerate(duration=2.5, samples=110250.))
