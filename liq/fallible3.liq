s = input.http("http://...")
s = fallback([s, blank()])
output.pulseaudio(s)
