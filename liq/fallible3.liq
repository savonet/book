s = input.http("http://...")
s = fallback(track_sensitive=false, [s, blank()])
output.pulseaudio(s)