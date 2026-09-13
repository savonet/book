#!./liquidsoap
def samplerate(~samples, ~duration) = samples / duration end
# header-a
samplerate(samples=110250., duration=2.5)
# footer-a
# header-b
samplerate(duration=2.5, samples=110250.)
