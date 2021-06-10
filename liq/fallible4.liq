s = buffer(input.http("http://..."))
s = mksafe(s)
output.pulseaudio(s)