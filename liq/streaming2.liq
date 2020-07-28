s = amplify(0.5, sine())
output.pulseaudio(s)
output.icecast(%mp3, mount="stream", s)
