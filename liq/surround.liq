#!./liquidsoap
# Test surround sound
audio.channels.set(6)
s = single("test.mp3")
output(s)
