#!./liquidsoap
def samplerate(~samples, ~duration=2.5) = samples / duration end
# header-a
samplerate(samples=110250.)
# footer-a
# header-b
samplerate(samples=132300., duration=3.)
